# 독립 MDX 파서의 자세를 원본 MOT 및 양자화된 스킨과 대조합니다.
import argparse
import json
from pathlib import Path

import numpy as np


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('model_folder', type=Path)
    args = parser.parse_args()
    root = args.model_folder
    conversion = json.loads((root/'conversion.json').read_text())
    comparisons = []
    for pose_file in sorted((root/'poses').glob('*.json')):
        source_file = root/(pose_file.stem+'.npz')
        if not source_file.exists():
            continue
        pose = json.loads(pose_file.read_text())
        with np.load(source_file) as source:
            actual, expected, original = [], [], []
            for geoset, mapping in zip(pose['geosets'], conversion['skin_maps']):
                indices = mapping['vertices']
                actual.extend(geoset['vertices'])
                expected.extend(source[mapping['entity']+'_quantized'][indices])
                original.extend(source[mapping['entity']+'_original'][indices])
            actual, expected, original = np.array(actual), np.array(expected), np.array(original)
            export_error = np.linalg.norm(actual-expected,axis=1)
            weight_error = np.linalg.norm(expected-original,axis=1)
            comparisons.append({'pose':pose_file.stem, 'vertices':len(actual),
                                'export_max_units':float(export_error.max()),
                                'export_rms_units':float(np.sqrt(np.mean(export_error**2))),
                                'weight_max_units':float(weight_error.max()),
                                'weight_rms_units':float(np.sqrt(np.mean(weight_error**2)))})
    if not comparisons:
        raise ValueError('No source/MDX pose pairs to compare')
    result = {'samples':len(comparisons), 'comparisons':comparisons}
    (root/'pose-comparison.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
    maximum = max(item['export_max_units'] for item in comparisons)
    print('POSES',len(comparisons),'EXPORT_MAX_UNITS',maximum,
          'WEIGHT_RMS_MAX_UNITS',max(item['weight_rms_units'] for item in comparisons))
    if maximum > 0.5:
        raise ValueError('Exported pose differs from the quantized source by more than 0.5 Warcraft units')


if __name__ == '__main__':
    main()
