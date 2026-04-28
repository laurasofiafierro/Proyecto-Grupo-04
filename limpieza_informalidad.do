*===============================================================================
* LIMPIEZA Y CONSTRUCCIÓN DE BASE DE INFORMALIDAD - GEIH 2022-2025
* Stata Bootcamp — G5
* Abril 2026
*===============================================================================

clear all
set more off

* Ruta de los datos (cambiar según la máquina)
global ruta "C:\Users\m4nuh\OneDrive\Documentos\Claude\Projects\Banca Central"

*===============================================================================
* 1. IMPORTAR LA BASE CRUDA
*===============================================================================

* La base fue construida a partir de los CSVs de la GEIH (formato nuevo, 2022+).
* Se unieron dos archivos por cada mes:
*   - "Ocupados.CSV": tiene las variables laborales (ingreso, posición, 
*     contrato, tamaño de empresa, pensión, ARL, horas, rama, oficio)
*   - "Características generales, seguridad social en salud y educación.CSV":
*     tiene las demográficas (sexo, edad, educación, salud, etnia)
* 
* El merge se hizo por DIRECTORIO + SECUENCIA_P + ORDEN + HOGAR.
* Los archivos están en carpetas: {año}/{mes}/  con meses Marzo, Junio,
* Septiembre y Diciembre (un mes representativo por trimestre).
* Separador: punto y coma. Encoding: latin-1 (por las ñ del DANE).

use "$ruta/informalidad_geih_2022_2025.dta", clear

describe, short
tab PERIODO, m

*===============================================================================
* 2. ETIQUETAS Y LIMPIEZA BÁSICA
*===============================================================================

* --- Identificadores ---
label variable DIRECTORIO  "ID vivienda"
label variable SECUENCIA_P "Secuencia persona"
label variable ORDEN       "Orden en el hogar"
label variable HOGAR       "ID hogar"
label variable ANIO        "Año"
label variable TRIMESTRE   "Trimestre (1=Mar, 2=Jun, 3=Sep, 4=Dic)"
label variable PERIODO     "Período (ej: 2022Q1)"
label variable DPTO        "Departamento"
label variable AREA        "Área (1=Cabecera, 2=Centro poblado, 3=Rural disperso)"
label variable FEX_C18     "Factor de expansión"
label variable MES         "Mes de la encuesta"

* --- Demográficas ---
label variable P3271 "Sexo (1=Hombre, 2=Mujer)"
label variable P6040 "Edad"
label variable P6050 "Parentesco con jefe del hogar"
label variable P6070 "Estado civil"
label variable P6080 "Autorreconocimiento étnico"

* Crear variable de sexo más legible
gen mujer = (P3271 == 2) if P3271 != .
label variable mujer "Mujer (1=Sí)"
label define lmujer 0 "Hombre" 1 "Mujer"
label values mujer lmujer

* --- Educación ---
label variable P3042 "Nivel educativo alcanzado"
label variable P3043 "Título o diploma obtenido"

* Agrupar nivel educativo en categorías manejables
* Codificación P3042 en GEIH nueva:
*  1=Ninguno, 2=Preescolar, 3=Primaria, 4=Secundaria, 5=Media,
*  6=Técnico, 7=Tecnológico, 8=Universitario, 9=Especialización,
*  10=Maestría, 11=Doctorado, 12=Normalista, 13=No sabe
gen nivel_educ = .
replace nivel_educ = 1 if inlist(P3042, 1, 2)       // Ninguno o preescolar
replace nivel_educ = 2 if P3042 == 3                 // Primaria
replace nivel_educ = 3 if P3042 == 4                 // Secundaria
replace nivel_educ = 4 if P3042 == 5                 // Media
replace nivel_educ = 5 if inlist(P3042, 6, 7, 12)    // Técnico/Tecnológico/Normalista
replace nivel_educ = 6 if P3042 == 8                 // Universitario
replace nivel_educ = 7 if inlist(P3042, 9, 10, 11)   // Posgrado

label variable nivel_educ "Nivel educativo (agrupado)"
label define lneduc 1 "Ninguno/Preescolar" 2 "Primaria" 3 "Secundaria" ///
    4 "Media" 5 "Técnico/Tecnológico" 6 "Universitario" 7 "Posgrado"
label values nivel_educ lneduc

* --- Variables laborales ---
label variable P6430 "Posición ocupacional"
* 1=Obrero/empleado empresa particular
* 2=Obrero/empleado gobierno
* 3=Empleado doméstico
* 4=Cuenta propia
* 5=Patrón/empleador
* 6=Trabajador familiar sin remuneración
* 7=Trabajador sin remuneración en otros hogares
* 8=Jornalero o peón

label define lposicion 1 "Obrero emp. particular" 2 "Obrero gobierno" ///
    3 "Empleado doméstico" 4 "Cuenta propia" 5 "Patrón/empleador" ///
    6 "Trab. familiar s/r" 7 "Trab. s/r otros hogares" 8 "Jornalero/peón"
label values P6430 lposicion

label variable P6440 "¿Tiene contrato? (1=Sí, 2=No)"
label variable P6450 "Tipo de contrato (1=Verbal, 2=Escrito)"
label variable P6500 "Ingreso mensual antes de descuentos (asalariados)"
label variable P6750 "Ganancia neta mensual (independientes)"
label variable INGLABO "Ingreso laboral total"
label variable P6800 "Horas trabajadas por semana"
label variable P6780 "Tipo de trabajo (ocasional, estacional, permanente)"
label variable P6880 "Lugar de trabajo"

* --- Seguridad social ---
label variable P6090  "¿Afiliado a salud? (1=Sí, 2=No)"
label variable P6100  "Régimen de salud (1=Contributivo, 2=Especial, 3=Subsidiado)"
label variable P6110  "¿Quién paga la afiliación?"
label variable P6920  "¿Cotiza a pensión? (1=Sí, 2=No, 3=Ya es pensionado)"
label variable P6940  "¿Quién paga la pensión?"
label variable P6990  "¿Afiliado a ARL? (1=Sí, 2=No)"
label variable P9450  "¿Afiliado a caja de compensación? (1=Sí, 2=No)"

* --- Empresa ---
label variable P3045S1 "¿Empresa tiene registro mercantil? (asalariados)"
label variable P3046   "¿Tiene contabilidad? (asalariados)"
label variable P3065   "¿Registrado en cámara de comercio? (independientes)"
label variable P3066   "¿Tiene contabilidad? (independientes)"
label variable P3067   "¿Registrado ante cámara de comercio? (independientes)"
label variable P3068   "¿Separa gastos hogar/negocio?"
label variable P3069   "Tamaño de la empresa"
label variable P6775   "¿El negocio lleva contabilidad?"
label variable P7075   "Tamaño empresa en segundo empleo"

label variable RAMA2D_R4 "Rama de actividad (2 dígitos CIIU)"
label variable OFICIO_C8 "Oficio (clasificación CNO)"

*===============================================================================
* 3. CONSTRUCCIÓN DE LA VARIABLE DE INFORMALIDAD
*===============================================================================

* Seguimos la definición del DANE que combina dos dimensiones:
*   Dimensión 1 — Sector informal: empresa sin registro o sin contabilidad,
*                  o empresa de hasta 5 trabajadores (P3069 <= 5 aprox.)
*   Dimensión 2 — Ocupación informal: no cotiza pensión, trabajador familiar
*                  sin remuneración, sin contrato, etc.

* --- Dimensión 1: Sector informal ---
* Una persona está en el sector informal si:
*   a) Trabaja en empresa que NO tiene registro mercantil (P3045S1==2 para 
*      asalariados, o P3065==2 / P3067==2 para independientes)
*   b) La empresa NO lleva contabilidad (P3046==2 asalariados, P3066==2 / 
*      P6775==2 independientes)
*   c) No se pueden separar gastos del hogar y negocio (P3068==2)
*   d) Empresa de 1 a 5 personas (P3069 <= 5, ó P3069 in {1,2,3,4,5})

* Proxy por tamaño: en la GEIH nueva, P3069 tiene categorías donde
* los valores 1-5 representan diferentes rangos pequeños
* 1=Trab. solo, 2=2-3, 3=4-5, 4=6-10, 5=11-19...

gen sector_informal = 0

* Por tamaño (hasta 5 personas) — las categorías 1, 2, 3 son <=5
replace sector_informal = 1 if inlist(P3069, 1, 2, 3)

* Por falta de registro mercantil
replace sector_informal = 1 if P3045S1 == 2  // asalariados sin registro
replace sector_informal = 1 if P3065 == 2    // independientes sin registro
replace sector_informal = 1 if P3067 == 2    // independientes sin registro (otra pregunta)

* Por falta de contabilidad
replace sector_informal = 1 if P3046 == 2    // asalariados
replace sector_informal = 1 if P3066 == 2    // independientes
replace sector_informal = 1 if P6775 == 2    // independientes

* Separación gastos hogar-negocio (si no puede separar -> informal)
replace sector_informal = 1 if P3068 == 2

* Gobierno siempre formal
replace sector_informal = 0 if P6430 == 2

label variable sector_informal "Sector informal (dimensión 1)"

* --- Dimensión 2: Ocupación informal ---
* Informal si: no cotiza a pensión, o es trabajador familiar sin remuneración,
* o no tiene contrato, o cotiza a régimen subsidiado.

gen ocup_informal = 0

* No cotiza a pensión (la más importante según DANE)
replace ocup_informal = 1 if P6920 == 2

* Trabajador familiar sin remuneración
replace ocup_informal = 1 if P6430 == 6
replace ocup_informal = 1 if P6430 == 7

* No tiene contrato (asalariados y empleados domésticos)
replace ocup_informal = 1 if P6440 == 2 & inlist(P6430, 1, 2, 3, 8)

* Régimen subsidiado (no contributivo)
replace ocup_informal = 1 if P6100 == 3

* Gobierno siempre formal
replace ocup_informal = 0 if P6430 == 2

label variable ocup_informal "Ocupación informal (dimensión 2)"

* --- Variable final: informal si cumple ambas dimensiones ---
* Según DANE: la convergencia de sector informal Y ocupación informal
gen informal = (sector_informal == 1 & ocup_informal == 1)
replace informal = . if P6430 == .  // missing si no tiene posición ocupacional

* Pero hay casos especiales que siempre son informales:
* Trabajadores familiares sin remuneración siempre son informales
replace informal = 1 if inlist(P6430, 6, 7)

* Jornaleros/peones sin pensión
replace informal = 1 if P6430 == 8 & P6920 == 2

label variable informal "Informal (def. DANE: sector ∩ ocupación)"
label define linf 0 "Formal" 1 "Informal"
label values informal linf

tab informal [iw=FEX_C18], m

*===============================================================================
* 4. VARIABLES DERIVADAS ADICIONALES
*===============================================================================

* Ingreso mensual unificado (asalariados + independientes)
gen double ingreso = P6500 if P6500 > 0 & P6500 != .
replace ingreso = P6750 if P6750 > 0 & P6750 != . & ingreso == .
replace ingreso = INGLABO if ingreso == . & INGLABO > 0 & INGLABO != .
label variable ingreso "Ingreso laboral mensual"

* Log del ingreso (para regresiones)
gen ln_ingreso = ln(ingreso) if ingreso > 0
label variable ln_ingreso "Log ingreso laboral"

* Rangos de edad
gen rango_edad = .
replace rango_edad = 1 if P6040 >= 15 & P6040 <= 24
replace rango_edad = 2 if P6040 >= 25 & P6040 <= 34
replace rango_edad = 3 if P6040 >= 35 & P6040 <= 44
replace rango_edad = 4 if P6040 >= 45 & P6040 <= 54
replace rango_edad = 5 if P6040 >= 55 & P6040 != .
label variable rango_edad "Rango de edad"
label define lredad 1 "15-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+"
label values rango_edad lredad

* Fecha trimestral para panel
gen qfecha = yq(ANIO, TRIMESTRE)
format qfecha %tq
label variable qfecha "Fecha trimestral"

* Zona (simplificada)
gen urbano = (AREA == 1) if AREA != .
label variable urbano "Zona urbana (cabecera)"
label define lurb 0 "Rural" 1 "Urbano"
label values urbano lurb

*===============================================================================
* 5. TASA DE INFORMALIDAD POR TRIMESTRE (verificación rápida)
*===============================================================================

* Esto debería dar valores cercanos al ~58% que reporta el DANE
tab PERIODO informal [iw=FEX_C18], row nofreq

*===============================================================================
* 6. GUARDAR BASE FINAL
*===============================================================================

compress
order DIRECTORIO SECUENCIA_P ORDEN HOGAR ANIO TRIMESTRE PERIODO qfecha ///
    DPTO AREA urbano MES FEX_C18 ///
    P3271 mujer P6040 rango_edad nivel_educ P3042 P3043 ///
    P6050 P6070 P6080 ///
    P6430 P6440 P6450 P6500 P6750 INGLABO ingreso ln_ingreso P6800 ///
    P6780 P6880 RAMA2D_R4 OFICIO_C8 ///
    P3045S1 P3046 P3065 P3066 P3067 P3068 P3069 P6775 P7075 ///
    P6090 P6100 P6110 P6920 P6940 P6990 P9450 ///
    sector_informal ocup_informal informal

save "$ruta/informalidad_geih_2022_2025.dta", replace

di "Base guardada: `c(N)' observaciones, `c(k)' variables"
di "Período: 2022Q1 - 2025Q4 (16 trimestres)"
