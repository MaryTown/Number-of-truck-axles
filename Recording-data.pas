procedure CheckEntry(i: integer);
var j: integer;
const
 DAxIn: int64 = 120; // пороговое отклонение по крайней оси для въезда
 DSEnd: int64 = 180; // пороговое отклонение по сумме осей для окончания въезда
 WeightIn: double = 0.18;
 WeightOut: double = 0.06;
begin
 with CardWeightLine[i] do
 begin
  //если линия была свободна и не в состоянии въезда и вес больше минимального
  if Vacant and not InEntry and (Weight >= WeightIn) then
  begin
   FromLeftToRight := (DL >= DAxIn) and (DR < DAxIn);
   FromRightToLeft := (DR >= DAxIn) and (DL < DAxIn);
   InEntry := FromLeftToRight or FromRightToLeft;
   ke := 0;
   log('Въезд=%d (%d/%d) линия %d Вес=%f ADC=%d %d %d %d DS=%d DL=%d DR=%d',
   [Ord(FromRightToLeft), DAxIn, DSEnd, i, PreWeight, PreADC[0], PreADC[1], PreADC[2], PreADC[3], PreDS, PreDL, PreDR], 3);//p
  end;
  if InEntry then // если идет въезд
  begin // сохраним соответсвующее значение
   if FromLeftToRight and not FromRightToLeft then Entry[ke] := DL;
   if not FromLeftToRight and FromRightToLeft then Entry[ke] := DR;
   inc(ke);
   log('Въезд=%d (%d/%d) линия %d Вес=%f ADC=%d %d %d %d DS=%d DL=%d DR=%d',
   [Ord(FromRightToLeft), DAxIn, DSEnd, i, Weight, ADC[0], ADC[1], ADC[2], ADC[3], DS, DL, DR], 3);//p
   if Vacant then Vacant := false // для первой точки дальнейшие проверки опустим
        else
    if DS < DSEnd then // если въезд закончился
     InEntry := false; // сбросим признак, что идет въезд
  end
        else // если въезд закончился просто контролируем вес на ок.0
   if not Vacant and (Weight <= WeightOut) then
   begin
    FromLeftToRight := false;
    FromRightToLeft := false;
    Vacant := true;
    for j:=0 to 127 do Entry[j] := 0; // очистим данные въезда
   end;
  log('Линия %d: DS=%d Vacant=%d L|R=%d|%d InEntry=%d Entry[%d]=%d',
    [i, DS, Ord(Vacant), Ord(FromLeftToRight), Ord(FromRightToLeft), Ord(InEntry), k, Entry[k]], 2);//p
 end;
end;
CardWeightLine : array [0..5] of record
  IsActive{, // активность весовой линии
  FreezeCard}: boolean;// заморозка чтения карт на линии
  Number, // номер весовой линии
  OperatingMode, // режим работы весовой линии
  PortN, Address, NumberScales, // порт, адрес весов РИТЕНВЕС, номер канала для весов
  NumberCardWIn, // номер канала для карты входа перед весами
  NumberCardWOut: integer; // номер канала карты выхода перед весами
  PreWeight, Weight: double; // текущий вес
  ADC, PreADC: array [0..3] of Word; // текущие/предыдущие показания АЦП по осям
  Entry: array [0..127] of int64; // данные по въезду авто для анализа
  ke: integer; // указатель в массиве Entry, он же его длина
  ADW: array [0..3, 0..127] of Word; // 128 последних значений АЦП по осям
  ADPL, ADPR, // для сумм значений АЦП по левой и правой площадкам
  ADS: array [0..127] of Cardinal; // для сумм значений АЦП по осям
  Ww: array [0..127] of double; // для значений веса
  k: integer; // текущий указатель в циклическом буфере
  DS, PreDS, // среднеквадратическое отклонение по 4 точкам для ADS
  DL, DR, DPL, DPR, PreDL, PreDR, PreDPL, PreDPR: int64; // отклонение по 2 точкам
  DW, PreDW: double; // отклонение по 2 точкам для Ww
  NoWeight, // нет действительного веса
  NewAD, // показания АЦП сменились
  Vacant, // линия свободна
  InEntry, // идет въезд на весы
  FromLeftToRight, FromRightToLeft: boolean; // направление въезда
  Ptick: Cardinal; // тик для исключения пропуска точек
  end;
function DispC(a: array of Cardinal; k, n: integer): int64;
var
  m, m2, ad: int64;
  j: integer;
  r: Comp;
begin
  m := 0;
  m2 := 0;
  for j:=1 to n do
  begin
    ad := a[(k-n+j) and 127];
    m := m + ad;
    m2 := m2 + ad*ad;
  end;
  m := m div n;
  m2 := m2 div n;
  r := m2 - m*m;
  result := round(sqrt(r));
end;
function DispW(a: array of Word; k, n: integer): int64;
var
  m, m2, ad: int64;
  j: integer;
  r: Comp;
begin
  m := 0;
  m2 := 0;
  for j:=1 to n do
  begin
    ad := a[(k-n+j) and 127];
    m := m + ad;
    m2 := m2 + ad*ad;
  end;
  m := m div n;
  m2 := m2 div n;
  r := m2 - m*m;
  result := round(sqrt(r));
end;
function DispR(a: array of Real; k, n: integer): Real;
var
  m, m2, ad, r: Real;
  j: integer;
begin
  m := 0;
  m2 := 0;
  for j:=1 to n do
  begin
    ad := a[(k-n+j) and 127];
    m := m + ad;
    m2 := m2 + ad*ad;
  end;
  m := m/n;
  m2 := m2/n;
  r := m2 - m*m;
  result := round(sqrt(r));
end;
