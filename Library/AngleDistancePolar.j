// ---
// # Euclid 라이브러리
//
// > 이 라이브러리는 게임 내 각종 좌표 및 각도 계산을 위한 기능을 제공합니다. 
// > 각도를 계산하여 유닛과 위젯의 방향을 조정하거나, 극좌표 시스템을 사용하여 
// > 특정 거리만큼 이동시킬 수 있는 다양한 유틸리티 함수들을 포함하고 있습니다.
//
// ## 작성자
// - **Name**: 동동주
// - **Mail**:  escaco95@naver.com
// - **GitHub**: [Euclid.j](https://github.com/escaco95/Warcraft-III-Libraries/blob/escaco/%EC%A2%85%EA%B2%B0%EA%B8%89/%EA%B3%B5%EC%9A%A9%20-%20Euclid%20%EA%B0%81%EB%8F%84%2C%20%EA%B1%B0%EB%A6%AC%2C%20%EC%A2%8C%ED%91%9C%20%EA%B3%84%EC%82%B0%20%EC%9C%A0%ED%8B%B8%EB%A6%AC%ED%8B%B0)
//
// ## 버전
// - **Version**: 20240902.0
//
// ## Changelog
// - **2024-09-02**: 좌표 관련 함수 추가 및 수정.
// - **2024-09-01**: 맵 저장 속도를 높이고, 의도치 않은 struct 역전 호출 문제를 해결하기 위해 function 으로 변경.
// - **2024-08-31**: (구) angle distance polar 라이브러리를 통합하여 Euclid 라이브러리로 재작성.
//
// ## 주요 기능:
// 1. **각도 조작 기능**:
//    - 두 좌표나 개체 간의 각도를 계산.
//    - 유닛이 특정 각도나 좌표를 바라보게 설정.
//    - 무작위 각도 생성.
//
// 2. **거리 계산 기능**:
//    - 좌표 간, 개체 간의 직선 거리 계산.
//
// 3. **극좌표 이동 기능**:
//    - 특정 각도와 거리만큼 좌표를 이동.
//    - 유닛이나 아이템을 특정 방향으로 이동.
//
// 4. **곡선 계산 기능**:
//    - 두 좌표 사이의 사인 곡선, 원호, 가속/감속 이동 등 다양한 곡선 경로 계산.
//    - Catmull-Rom 곡선과 베지어 곡선 지원.
//
// 5. **좌표 제한 기능**:
//    - 좌표를 특정 원 또는 사각형 내로 제한.
//
// ## 활용 시나리오:
// - 유닛이나 프로젝트가 특정 지점을 향해 이동하는 게임 로직.
// - 유닛들이 특정 각도로 이동하거나 회전할 때.
// - 복잡한 곡선 이동을 구현할 때 (예: 유도 미사일 경로).
// - 게임 맵에서 특정 범위 내에 좌표를 제한할 때.
//
// 이 라이브러리는 게임 개발 시 반복적으로 사용되는 좌표 및 각도 계산을 단순화하고 
// 코드의 재사용성을 높이기 위해 설계되었습니다.
// ---
library Euclid

    private function AngleCycle takes real a, real b, real c returns real
        local real d = c - b
        local real v = ModuloReal(a-b,d)
        if v < 0 then
            set v = v + d
        endif
        return b + v
    endfunction

    // ## 각도 - 현재 각도가 목표 각도를 향하도록 delta 만큼 회전합니다.
    function AngleTrans takes real currentAngle, real targetAngle, real delta returns real
        return currentAngle + RMaxBJ(-delta, RMinBJ(delta, AngleCycle(targetAngle - currentAngle, -180, 180)))
    endfunction
    
    // ## 각도 - 무작위 각도(0~360)를 가져옵니다.
    function AngleRandom takes nothing returns real
        return GetRandomReal(0.0,360.0)
    endfunction

    // ## 각도 - 좌표가 좌표를 바라보는 각도를 계산합니다.
    function AnglePBP takes real x, real y, real tx, real ty returns real
        return Atan2( ty - y, tx - x ) * bj_RADTODEG
    endfunction

    // ## 각도 - 좌표가 개체를 바라보는 각도를 계산합니다.
    function AnglePBW takes real x, real y, widget t returns real
        return Atan2( GetWidgetY(t) - y, GetWidgetX(t) - x ) * bj_RADTODEG
    endfunction

    // ## 각도 - 개체가 좌표를 바라보는 각도를 계산합니다.
    function AngleWBP takes widget w, real tx, real ty returns real
        return Atan2( ty - GetWidgetY(w), tx - GetWidgetX(w) ) * bj_RADTODEG
    endfunction

    // ## 각도 - 개체가 개체를 바라보는 각도를 계산합니다.
    function AngleWBW takes widget w, widget t returns real
        return Atan2( GetWidgetY(t) - GetWidgetY(w), GetWidgetX(t) - GetWidgetX(w) ) * bj_RADTODEG
    endfunction

    // ## 각도 - 유닛이 각도를 바라보게 합니다.
    function AngleUTA takes unit u, real angle returns nothing
        call SetUnitFacing(u,angle)
    endfunction

    // ## 각도 - 유닛이 좌표를 바라보게 합니다.
    function AngleUTP takes unit u, real x, real y returns nothing
        call SetUnitFacing(u,Atan2(y-GetWidgetY(u), x-GetWidgetX(u))*bj_RADTODEG)
    endfunction

    // ## 각도 - 유닛이 개체를 바라보게 합니다.
    function AngleUTW takes unit u, widget t returns nothing
        call SetUnitFacing(u,Atan2(GetWidgetY(t)-GetWidgetY(u), GetWidgetX(t)-GetWidgetX(u))*bj_RADTODEG)
    endfunction

    // ## 각도 - 무작위 호도(0.0~6.28)를 가져옵니다.
    function AngleRadRandom takes nothing returns real
        return GetRandomReal(0.0,bj_PI*2)
    endfunction

    // ## 각도 - 좌표가 좌표를 바라보는 라디안 각도를 계산합니다.
    function AngleRadPBP takes real x, real y, real tx, real ty returns real
        return Atan2( ty - y, tx - x )
    endfunction

    // ## 각도 - 좌표가 개체를 바라보는 라디안 각도를 계산합니다.
    function AngleRadPBW takes real x, real y, widget t returns real
        return Atan2( GetWidgetY(t) - y, GetWidgetX(t) - x )
    endfunction

    // ## 각도 - 개체가 좌표를 바라보는 라디안 각도를 계산합니다.
    function AngleRadWBP takes widget w, real tx, real ty returns real
        return Atan2( ty - GetWidgetY(w), tx - GetWidgetX(w) )
    endfunction

    // ## 각도 - 개체가 개체를 바라보는 라디안 각도를 계산합니다.
    function AngleRadWBW takes widget w, widget t returns real
        return Atan2( GetWidgetY(t) - GetWidgetY(w), GetWidgetX(t) - GetWidgetX(w) )
    endfunction

    // ## 각도 - 유닛이 라디안 각도를 바라보게 합니다.
    function AngleRadUTA takes unit u, real angle returns nothing
        call SetUnitFacing(u,angle*bj_RADTODEG)
    endfunction

    // ## 거리 - 좌표와 좌표 간의 거리를 계산합니다.
    function DistancePBP takes real x, real y, real tx, real ty returns real
        local real dx = tx - x
        local real dy = ty - y
        return SquareRoot( dx * dx + dy * dy )
    endfunction

    // ## 거리 - 좌표와 개체 간의 거리를 계산합니다.
    function DistancePBW takes real x, real y, widget t returns real
        local real dx = GetWidgetX( t ) - x
        local real dy = GetWidgetY( t ) - y
        return SquareRoot( dx * dx + dy * dy )
    endfunction

    // ## 거리 - 개체와 좌표 간의 거리를 계산합니다.
    function DistanceWBP takes widget w, real tx, real ty returns real
        local real dx = tx - GetWidgetX( w )
        local real dy = ty - GetWidgetY( w )
        return SquareRoot( dx * dx + dy * dy )
    endfunction

    // ## 거리 - 개체와 개체 간의 거리를 계산합니다.
    function DistanceWBW takes widget w, widget t returns real
        local real dx = GetWidgetX( t ) - GetWidgetX( w )
        local real dy = GetWidgetY( t ) - GetWidgetY( w )
        return SquareRoot( dx * dx + dy * dy )
    endfunction

    // ## 극좌표 - 특정 거리만큼 특정 각도로 이동하였을 때의 X값을 반환합니다.
    function PolarX takes real dist, real angle returns real
        return dist * Cos( angle * bj_DEGTORAD )
    endfunction

    // ## 극좌표 - 특정 거리만큼 특정 각도로 이동하였을 때의 Y값을 반환합니다.
    function PolarY takes real dist, real angle returns real
        return dist * Sin( angle * bj_DEGTORAD )
    endfunction

    // ## 극좌표 - 유닛을 특정 거리만큼 특정 각도를 향해 이동시킵니다.
    function PolarUTA takes unit u, real dist, real angle returns nothing
        call SetUnitX(u, GetUnitX(u)+ dist * Cos(angle * bj_DEGTORAD))
        call SetUnitY(u, GetUnitY(u)+ dist * Sin(angle * bj_DEGTORAD))
    endfunction

    // ## 극좌표 - 유닛을 특정 거리만큼 특정 좌표를 향해 이동시킵니다.
    function PolarUTP takes unit u, real dist, real x, real y returns nothing
        local real angle = Atan2(y-GetWidgetY(u), x-GetWidgetX(u))
        call SetUnitX(u, GetUnitX(u)+ dist * Cos(angle))
        call SetUnitY(u, GetUnitY(u)+ dist * Sin(angle))
    endfunction

    // ## 극좌표 - 유닛을 특정 거리만큼 특정 위젯을 향해 이동시킵니다.
    function PolarUTW takes unit u, real dist, widget t returns nothing
        local real angle = Atan2(GetWidgetY(t)-GetWidgetY(u), GetWidgetX(t)-GetWidgetX(u))
        call SetUnitX(u, GetUnitX(u)+ dist * Cos(angle))
        call SetUnitY(u, GetUnitY(u)+ dist * Sin(angle))
    endfunction

    // ## 극좌표 - 아이템을 특정 거리만큼 특정 각도를 향해 이동시킵니다.
    function PolarITA takes item i, real dist, real angle returns nothing
        call SetItemPosition(i,GetWidgetX(i)+ dist * Cos(angle * bj_DEGTORAD),GetWidgetY(i)+ dist * Sin(angle * bj_DEGTORAD))
    endfunction

    // ## 극좌표 - 아이템을 특정 거리만큼 특정 좌표를 향해 이동시킵니다.
    function PolarITP takes item i, real dist, real x, real y returns nothing
        local real angle = Atan2(y-GetWidgetY(i), x-GetWidgetX(i))
        call SetItemPosition(i,GetWidgetX(i)+ dist * Cos(angle),GetWidgetY(i)+ dist * Sin(angle))
    endfunction

    // ## 극좌표 - 아이템을 특정 거리만큼 특정 위젯을 향해 이동시킵니다.
    function PolarITW takes item i, real dist, widget t returns nothing
        local real angle = Atan2(GetWidgetY(t)-GetWidgetY(i), GetWidgetX(t)-GetWidgetX(i))
        call SetItemPosition(i,GetWidgetX(i)+ dist * Cos(angle),GetWidgetY(i)+ dist * Sin(angle))
    endfunction

    // ## 극좌표 - 특정 거리만큼 특정 라디안 각도로 이동하였을 때의 X값을 반환합니다.
    function PolarRadX takes real dist, real angle returns real
        return dist * Cos( angle )
    endfunction

    // ## 극좌표 - 특정 거리만큼 특정 라디안 각도로 이동하였을 때의 Y값을 반환합니다.
    function PolarRadY takes real dist, real angle returns real
        return dist * Sin( angle )
    endfunction

    // ## 극좌표 - 유닛을 특정 거리만큼 특정 각도를 향해 이동시킵니다.
    function PolarRadUTA takes unit u, real dist, real angle returns nothing
        call SetUnitX(u, GetUnitX(u)+ dist * Cos(angle))
        call SetUnitY(u, GetUnitY(u)+ dist * Sin(angle))
    endfunction

    // ## 극좌표 - 아이템을 특정 거리만큼 특정 각도를 향해 이동시킵니다.
    function PolarRadITA takes item i, real dist, real angle returns nothing
        call SetItemPosition(i,GetWidgetX(i)+ dist * Cos(angle),GetWidgetY(i)+ dist * Sin(angle))
    endfunction

    // ## 극좌표(+방향) - 유닛을 특정 거리만큼 특정 각도를 향해 이동시킵니다.
    function PolarAngleUTA takes unit u, real dist, real angle returns nothing
        call SetUnitX(u, GetUnitX(u)+ dist * Cos(angle * bj_DEGTORAD))
        call SetUnitY(u, GetUnitY(u)+ dist * Sin(angle * bj_DEGTORAD))
        call SetUnitFacing(u,angle)
    endfunction

    // ## 극좌표(+방향) - 유닛을 특정 거리만큼 특정 좌표를 향해 이동시킵니다.
    function PolarAngleUTP takes unit u, real dist, real x, real y returns nothing
        local real angle = Atan2(y-GetWidgetY(u), x-GetWidgetX(u))
        call SetUnitX(u, GetUnitX(u)+ dist * Cos(angle))
        call SetUnitY(u, GetUnitY(u)+ dist * Sin(angle))
        call SetUnitFacing(u,angle*bj_RADTODEG)
    endfunction

    // ## 극좌표(+방향) - 유닛을 특정 거리만큼 특정 위젯을 향해 이동시킵니다.
    function PolarAngleUTW takes unit u, real dist, widget t returns nothing
        local real angle = Atan2(GetWidgetY(t)-GetWidgetY(u), GetWidgetX(t)-GetWidgetX(u))
        call SetUnitX(u, GetUnitX(u)+ dist * Cos(angle))
        call SetUnitY(u, GetUnitY(u)+ dist * Sin(angle))
        call SetUnitFacing(u,angle*bj_RADTODEG)
    endfunction

    // ## 극좌표(+방향) - 유닛을 특정 거리만큼 특정 라디안 각도를 향해 이동시킵니다.
    function PolarAngleRadUTA takes unit u, real dist, real angle returns nothing
        call SetUnitX(u, GetUnitX(u)+ dist * Cos(angle))
        call SetUnitY(u, GetUnitY(u)+ dist * Sin(angle))
        call SetUnitFacing(u,angle*bj_RADTODEG)
    endfunction

    globals
        private real CURVE_X = 0.0
        private real CURVE_Y = 0.0
        private real CURVE_Z = 0.0
    endglobals

    // ## 곡선 - 계산 결과 X좌표값을 받아옵니다.
    function CurveX takes nothing returns real
        return CURVE_X
    endfunction

    // ## 곡선 - 계산 결과 Y좌표값을 받아옵니다.
    function CurveY takes nothing returns real
        return CURVE_Y
    endfunction

    // ## 곡선 - 계산 결과 Z좌표값을 받아옵니다.
    function CurveZ takes nothing returns real
        return CURVE_Z
    endfunction

    // ## 곡선 - 두 좌표를 잇는 사인 곡선을 계산합니다.
    function CurveSin takes real x1, real y1, real z1, real x2, real y2, real z2, real h, real p returns nothing
        set CURVE_X = x1 + p * (x2 - x1)
        set CURVE_Y = y1 + p * (y2 - y1)
        set CURVE_Z = z1 + p * (z2 - z1) + h * Sin( bj_PI * p )
    endfunction

    // ## 곡선 - 두 좌표를 잇는 원호 곡선을 계산합니다.
    function CurveArc takes real x1, real y1, real z1, real x2, real y2, real z2, real radius, real p returns nothing
        local real angle = Atan2(y2 - y1, x2 - x1)
        local real d = SquareRoot((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
        local real a = angle + (p - 0.5) * (d / radius)
    
        set CURVE_X = x1 + radius * Cos(a)
        set CURVE_Y = y1 + radius * Sin(a)
        set CURVE_Z = z1 + p * (z2 - z1)
    endfunction

    // ## 곡선 - 두 좌표 위를 가속/감속하며 이동하는 곡선을 계산합니다.
    function CurveEase takes real x1, real y1, real z1, real x2, real y2, real z2, real p returns nothing
        local real p2 = p * p
        local real p_inv = 1.0 - p
        local real p2_inv = p_inv * p_inv
    
        set CURVE_X = p2_inv * x1 + p2 * x2
        set CURVE_Y = p2_inv * y1 + p2 * y2
        set CURVE_Z = p2_inv * z1 + p2 * z2
    endfunction

    // ## 곡선 - 4개 좌표를 통과하는 Catmull-Rom 곡선을 계산합니다.
    function CurveCatmullRom takes real x0, real y0, real z0, real x1, real y1, real z1, real x2, real y2, real z2, real x3, real y3, real z3, real p returns nothing
        local real p2 = p * p
        local real p3 = p2 * p
    
        set CURVE_X = 0.5 * ((2 * x1) + (-x0 + x2) * p + (2*x0 - 5*x1 + 4*x2 - x3) * p2 + (-x0 + 3*x1 - 3*x2 + x3) * p3)
        set CURVE_Y = 0.5 * ((2 * y1) + (-y0 + y2) * p + (2*y0 - 5*y1 + 4*y2 - y3) * p2 + (-y0 + 3*y1 - 3*y2 + y3) * p3)
        set CURVE_Z = 0.5 * ((2 * z1) + (-z0 + z2) * p + (2*z0 - 5*z1 + 4*z2 - z3) * p2 + (-z0 + 3*z1 - 3*z2 + z3) * p3)
    endfunction

    // ## 곡선 - 두 좌표를 경유하는 베지어 곡선을 계산합니다.
    function CurveBezier1 takes real x1, real y1, real z1, real x2, real y2, real z2, real p returns nothing
        local real oneMinusP = 1.0 - p
        set CURVE_X = oneMinusP * x1 + p * x2
        set CURVE_Y = oneMinusP * y1 + p * y2
        set CURVE_Z = oneMinusP * z1 + p * z2
    endfunction

    // ## 곡선 - 3개 좌표를 경유하는 베지어 곡선을 계산합니다.
    function CurveBezier2 takes real x1, real y1, real z1, real x2, real y2, real z2, real x3, real y3, real z3, real p returns nothing
        local real oneMinusP = 1.0 - p
        set CURVE_X = oneMinusP * oneMinusP * x1 + 2 * oneMinusP * p * x2 + p * p * x3
        set CURVE_Y = oneMinusP * oneMinusP * y1 + 2 * oneMinusP * p * y2 + p * p * y3
        set CURVE_Z = oneMinusP * oneMinusP * z1 + 2 * oneMinusP * p * z2 + p * p * z3
    endfunction

    // ## 곡선 - 4개 좌표를 경유하는 베지어 곡선을 계산합니다.
    function CurveBezier3 takes real x1, real y1, real z1, real x2, real y2, real z2, real x3, real y3, real z3, real x4, real y4, real z4, real p returns nothing
        local real oneMinusP = 1.0 - p
        set CURVE_X = oneMinusP * oneMinusP * oneMinusP * x1 + 3 * oneMinusP * oneMinusP * p * x2 + 3 * oneMinusP * p * p * x3 + p * p * p * x4
        set CURVE_Y = oneMinusP * oneMinusP * oneMinusP * y1 + 3 * oneMinusP * oneMinusP * p * y2 + 3 * oneMinusP * p * p * y3 + p * p * p * y4
        set CURVE_Z = oneMinusP * oneMinusP * oneMinusP * z1 + 3 * oneMinusP * oneMinusP * p * z2 + 3 * oneMinusP * p * p * z3 + p * p * p * z4
    endfunction

    globals
        private real POINT_X = 0.0
        private real POINT_Y = 0.0
    endglobals

    // ## 좌표 - X값을 가져옵니다.
    function PointX takes nothing returns real
        return POINT_X
    endfunction

    // ## 좌표 - Y값을 가져옵니다.
    function PointY takes nothing returns real
        return POINT_Y
    endfunction

    // ## 좌표 - 좌표를 초기화합니다.
    function PointReset takes nothing returns nothing
        set POINT_X = 0.0
        set POINT_Y = 0.0
    endfunction

    // ## 좌표 - 좌표를 설정합니다.
    function Point takes real x, real y returns nothing
        set POINT_X = x
        set POINT_Y = y
    endfunction

    // ## 좌표 - 좌표를 객체의 좌표로 설정합니다.
    function PointWidget takes widget w returns nothing
        set POINT_X = GetWidgetX(w)
        set POINT_Y = GetWidgetY(w)
    endfunction

    // ## 좌표 - 좌표의 X축을 객체의 X축으로 설정합니다.
    function PointWidgetX takes widget w returns nothing
        set POINT_X = GetWidgetX(w)
    endfunction

    // ## 좌표 - 좌표의 Y축을 객체의 Y축으로 설정합니다.
    function PointWidgetY takes widget w returns nothing
        set POINT_Y = GetWidgetY(w)
    endfunction

    // ## 좌표 - 좌표를 유닛의 좌표로 설정합니다.
    function PointUnit takes unit u returns nothing
        set POINT_X = GetUnitX(u)
        set POINT_Y = GetUnitY(u)
    endfunction

    // ## 좌표 - 좌표의 X축을 유닛의 X축으로 설정합니다.
    function PointUnitX takes unit u returns nothing
        set POINT_X = GetUnitX(u)
    endfunction

    // ## 좌표 - 좌표의 Y축을 유닛의 Y축으로 설정합니다.
    function PointUnitY takes unit u returns nothing
        set POINT_Y = GetUnitY(u)
    endfunction

    // ## 좌표 - 좌표를 아이템의 좌표로 설정합니다.
    function PointItem takes item i returns nothing
        set POINT_X = GetItemX(i)
        set POINT_Y = GetItemY(i)
    endfunction

    // ## 좌표 - 좌표의 X축을 아이템의 X축으로 설정합니다.
    function PointItemX takes item i returns nothing
        set POINT_X = GetItemX(i)
    endfunction

    // ## 좌표 - 좌표의 Y축을 아이템의 Y축으로 설정합니다.
    function PointItemY takes item i returns nothing
        set POINT_Y = GetItemY(i)
    endfunction

    // ## 좌표 - 좌표를 플레이어의 시작 위치로 설정합니다.
    function PointPlayer takes player p returns nothing
        set POINT_X = GetStartLocationX(GetPlayerStartLocation(p))
        set POINT_Y = GetStartLocationY(GetPlayerStartLocation(p))
    endfunction

    // ## 좌표 - 좌표를 이동합니다.
    function PointMove takes real x, real y returns nothing
        set POINT_X = POINT_X + x
        set POINT_Y = POINT_Y + y
    endfunction

    // ## 좌표 - 좌표의 X축을 이동합니다.
    function PointMoveX takes real x returns nothing
        set POINT_X = POINT_X + x
    endfunction

    // ## 좌표 - 좌표의 Y축을 이동합니다.
    function PointMoveY takes real y returns nothing
        set POINT_Y = POINT_Y + y
    endfunction

    // ## 좌표 - 좌표를 지정한 중심점을 기준으로 회전합니다.
    function PointRotate takes real x, real y, real angle returns nothing
        local real cosA = Cos(angle * bj_DEGTORAD)
        local real sinA = Sin(angle * bj_DEGTORAD)
        local real dx = POINT_X - x
        local real dy = POINT_Y - y
        set POINT_X = x + dx * cosA - dy * sinA
        set POINT_Y = y + dx * sinA + dy * cosA
    endfunction

    // ## 좌표 - 좌표를 지정한 중심점을 기준으로 호의 길이만큼 회전합니다.
    function PointRotateArc takes real x, real y, real arc returns nothing
        local real dx = POINT_X - x
        local real dy = POINT_Y - y
        local real radius = SquareRoot(dx * dx + dy * dy)
        local real angle = arc / radius
        local real cosA = Cos(angle)
        local real sinA = Sin(angle)
        set POINT_X = x + dx * cosA - dy * sinA
        set POINT_Y = y + dx * sinA + dy * cosA
    endfunction

    // ## 좌표 - 좌표를 지정한 거리, 각도로 이동합니다.
    function PointPolar takes real dist, real angle returns nothing
        set POINT_X = POINT_X + dist * Cos(angle * bj_DEGTORAD)
        set POINT_Y = POINT_Y + dist * Sin(angle * bj_DEGTORAD)
    endfunction

    // ## 좌표 - 좌표를 지정한 거리, 라디안 각도로 이동합니다.
    function PointPolarRad takes real dist, real angle returns nothing
        set POINT_X = POINT_X + dist * Cos(angle)
        set POINT_Y = POINT_Y + dist * Sin(angle)
    endfunction

    // ## 좌표 - 좌표를 지정한 거리만큼 지정한 좌표를 향해 이동합니다.
    function PointTowardPoint takes real dist, real x, real y returns nothing
        local real angle = Atan2(y - POINT_Y, x - POINT_X)
        set POINT_X = POINT_X + dist * Cos(angle)
        set POINT_Y = POINT_Y + dist * Sin(angle)
    endfunction

    // ## 좌표 - 좌표를 지정한 거리만큼 지정한 위젯을 향해 이동합니다.
    function PointTowardWidget takes real dist, widget t returns nothing
        local real angle = Atan2(GetWidgetY(t) - POINT_Y, GetWidgetX(t) - POINT_X)
        set POINT_X = POINT_X + dist * Cos(angle)
        set POINT_Y = POINT_Y + dist * Sin(angle)
    endfunction

    // ## 좌표 - 좌표를 지정한 반지름 내 무작위 좌표로 흩뿌립니다.
    function PointSpreadCircle takes real radius returns nothing
        local real angle = GetRandomReal(0.0, bj_PI * 2)
        local real dist = GetRandomReal(0.0, radius) * SquareRoot(GetRandomReal(0.0, 1.0))
        set POINT_X = POINT_X + radius * Cos(angle)
        set POINT_Y = POINT_Y + radius * Sin(angle)
    endfunction

    // ## 좌표 - 좌표를 지정한 사각형 내 무작위 좌표로 흩뿌립니다.
    function PointSpreadRect takes real width, real height returns nothing
        set POINT_X = POINT_X + GetRandomReal(-width, width)
        set POINT_Y = POINT_Y + GetRandomReal(-height, height)
    endfunction

    // ## 좌표 - 좌표를 지정한 사각형 내로 제한합니다.
    function PointLimitRect takes rect r returns nothing
        set POINT_X = RMaxBJ(GetRectMinX(r), RMinBJ(GetRectMaxX(r), POINT_X))
        set POINT_Y = RMaxBJ(GetRectMinY(r), RMinBJ(GetRectMaxY(r), POINT_Y))
    endfunction

    // ## 좌표 - 좌표를 지정한 원 내로 제한합니다.
    function PointLimitCircle takes real x, real y, real radius returns nothing
        local real dx = POINT_X - x
        local real dy = POINT_Y - y
        local real dist = SquareRoot(dx * dx + dy * dy)
    
        // 좌표가 원의 반지름을 벗어났다면
        if dist > radius then
            // 원의 경계상 가장 가까운 지점으로 이동
            set POINT_X = x + dx * (radius / dist)
            set POINT_Y = y + dy * (radius / dist)
        endif
    endfunction

    // ## 좌표 - 유닛의 X축 좌표를 지정한 좌표로 설정합니다.
    function PointBringUnitX takes unit u returns nothing
        call SetUnitX(u, POINT_X)
    endfunction

    // ## 좌표 - 유닛의 Y축 좌표를 지정한 좌표로 설정합니다.
    function PointBringUnitY takes unit u returns nothing
        call SetUnitY(u, POINT_Y)
    endfunction

    // ## 좌표 - 유닛의 X축 좌표와 Y축 좌표를 지정한 좌표로 설정합니다.
    // ℹ️ X좌표가 먼저 이동된 후 Y좌표가 이동됩니다.
    // ⚠️ 장거리 이동 시 주의하여 사용하십시오.
    // 🚨 각 좌표가 따로따로 이동되므로, 의도치 않은 위치에 이동 판정이 발생할 수 있습니다.
    function PointBringUnitXY takes unit u returns nothing
        call SetUnitX(u, POINT_X)
        call SetUnitY(u, POINT_Y)
    endfunction

    // ## 좌표 - 유닛을 현재 좌표로 가져옵니다.
    // ℹ️ 유닛의 위치가 즉시 이동됩니다.
    // ⚠️ 유닛이 받은 명령이 취소됩니다.
    // ⚠️ 유닛이 재생 중인 애니메이션이 중단될 수 있습니다.
    function PointBringUnit takes unit u returns nothing
        call SetUnitPosition(u, POINT_X, POINT_Y)
    endfunction

    // ## 좌표 - 아이템을 현재 좌표로 가져옵니다.
    // ⚠️ 숨겨져 있던 아이템일 경우 보이게 됩니다.
    // ⚠️ 누군가 들고 있던 아이템일 경우 바닥에 떨어집니다.
    function PointBringItem takes item i returns nothing
        call SetItemPosition(i, POINT_X, POINT_Y)
    endfunction

    globals
        private real array POINT_X_STACK
        private real array POINT_Y_STACK
        private integer POINT_STACK_INDEX = 0
    endglobals

    // ## 좌표 - 현재 좌표를 스택에 저장합니다.
    // ℹ️ 트리거 간 좌표 계산 간섭을 방지하기 위해 사용됩니다.
    // ⚠️ 좌표는 최대 8191 중첩까지 스택 가능합니다.
    // ⚠️ `PointPush`와 `PointPop`은 반드시 쌍으로 사용되어야 합니다.
    // 🚨 만약 개발자 실수로 중첩 한계치를 넘기게 되면 반드시 페이탈 오류가 발생하게 됩니다. 
    // ---
    // **사용예시**
    // > `call PointPush( )`
    // > `// 이 사이에 Point 기능으로 하고 싶은 작업을 모두 코드로 작성`
    // > `call PointPop( )`
    // ---
    function PointPush takes nothing returns nothing
        set POINT_STACK_INDEX = POINT_STACK_INDEX + 1
        set POINT_X_STACK[POINT_STACK_INDEX] = POINT_X
        set POINT_Y_STACK[POINT_STACK_INDEX] = POINT_Y
    endfunction

    // ## 좌표 - 스택에 저장된 좌표를 불러옵니다.
    // ℹ️ 트리거 간 좌표 계산 간섭을 방지하기 위해 사용됩니다.
    function PointPop takes nothing returns nothing
        if POINT_STACK_INDEX <= 0 then
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 3600, "|cFFFF0000[FATAL] ERROR!! 좌표 스택이 비어있으나 PointPop 함수가 호출되었습니다!!|r")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 3600, "스크립트 어딘가에서 PointPush 와 PointPop 함수의 쌍이 맞지 않는 문제가 발생한 게 분명합니다.")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 3600, "전수조사를 통해 문제를 해결하지 않을 경우, 좌표 기반 스크립트들이 모두 오작동할 수 있습니다.")
            return
        endif
        set POINT_X = POINT_X_STACK[POINT_STACK_INDEX]
        set POINT_Y = POINT_Y_STACK[POINT_STACK_INDEX]
        set POINT_STACK_INDEX = POINT_STACK_INDEX - 1
    endfunction

endlibrary