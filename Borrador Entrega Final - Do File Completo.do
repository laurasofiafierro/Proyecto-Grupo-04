/* 
___________________________________________________________________________________________________

      DO-FILE - EVOLUCIÓN Y PERFIL DEL TRABAJADOR INFORMAL EN COLOMBIA: 
                DINÁMICAS DE GÉNERO Y BRECHAS EDUCATIVAS PARA EL PERIODO 2022–2025

          Equipo de Investigación (G4) : Fierro Caviedes Laura Sofia, Tovar Lugo David Enrique, 
    Rodriguez Barrera Dumar Santiago, Hernandez Silva Manuel Santiago, Soto Ballén Zahir Nicolas.

          Fecha de elaboración: 26 de Mayo 2026.
__________________________________________________________________________________________________
                                1. IMPORTACIÓN DE BASE CRUDA
__________________________________________________________________________________________________

La base fue construida a partir de los CSVs de la GEIH (formato nuevo, 2022+). 
En las que se unieron dos archivos por cada mes:

     1) "Ocupados.CSV": tiene las variables laborales (ingreso, posición, 
          contrato, tamaño de empresa, pensión, ARL, horas, rama, oficio)

      2) "Características generales, seguridad social en salud y educación.CSV":
           tiene las demográficas (sexo, edad, educación, salud, etnia)

      * El merge se hizo por DIRECTORIO + SECUENCIA_P + ORDEN + HOGAR.

Los archivos se encuentran en carpetas con el formato: {año}/{mes}/  
con meses Marzo, Junio, Septiembre y Diciembre (Mes representativo por cada trimestre).

      * Separador: punto y coma. 
        Encoding: latin-1 (por las ñ del DANE).
*/

clear all
set more off

* Ruta de los datos (cambiar según dispositivo)
global ruta "C:\Users\m4nuh\OneDrive\Documentos\Claude\Projects\Banca Central"

use "$ruta/informalidad_geih_2022_2025.dta", clear

* Información de la data
describe, short

* Tabla de los periodos (Por mes)
tab PERIODO, m

*/
____________________________________________________________________________________________________
                           2. ETIQUETAS DE VARIABLES Y LIMPIEZA DE BASE
____________________________________________________________________________________________________

*/

* -------------------------------------- Identificadores -------------------------------------------

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

* ------------------------------------------ Demográficas -------------------------------------------

label variable P3271 "Sexo (1=Hombre, 2=Mujer)"
label variable P6040 "Edad"
label variable P6050 "Parentesco con jefe del hogar"
label variable P6070 "Estado civil"
label variable P6080 "Autorreconocimiento étnico"

* ------------------------------------ Creación de Variable Sexo ------------------------------------

gen mujer = (P3271 == 2) if P3271 != .
label variable mujer "Mujer (1=Sí)"
label define lmujer 0 "Hombre" 1 "Mujer"
label values mujer lmujer

* -------------------------------------------- Educación -------------------------------------------

label variable P3042 "Nivel educativo alcanzado"
label variable P3043 "Título o diploma obtenido"

* ---------------------------------- Agrupación por Nivel Educativo ---------------------------------

/*
        Se realiza una agrupación por nivel educativo en categorías manejables 
        Usando la Codificación P3042 en GEIH nueva:

        1=Ninguno, 2=Preescolar, 3=Primaria, 4=Secundaria, 5=Media,
        6=Técnico, 7=Tecnológico, 8=Universitario, 9=Especialización,
        10=Maestría, 11=Doctorado, 12=Normalista, 13=No sabe

*/

gen nivel_educ = .
replace nivel_educ = 1 if inlist(P3042, 1, 2)        // Ninguno o preescolar
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


* ---------------------------------- Variables laborales --------------------------------------------

label variable P6430 "Posición ocupacional"

/*  1 = Obrero/empleado(a) empresa particular
    2 = Obrero/empleado(a) gobierno
    3 = Empleado(a) doméstico(a)
    4 = Cuenta propia
    5 = Patrón/empleador(a)
    6 = Trabajador(a) familiar sin remuneración
    7 = Trabajador(a) sin remuneración en otros hogares
    8 = Jornalero (a) o peón
*/

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

* ---------------------------------- Seguridad Social -----------------------------------------------

label variable P6090  "¿Afiliado a salud? (1=Sí, 2=No)"
label variable P6100  "Régimen de salud (1=Contributivo, 2=Especial, 3=Subsidiado)"
label variable P6110  "¿Quién paga la afiliación?"
label variable P6920  "¿Cotiza a pensión? (1=Sí, 2=No, 3=Ya es pensionado)"
label variable P6940  "¿Quién paga la pensión?"
label variable P6990  "¿Afiliado a ARL? (1=Sí, 2=No)"
label variable P9450  "¿Afiliado a caja de compensación? (1=Sí, 2=No)"

* -------------------------------------- Empresa ----------------------------------------------------

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

*/
____________________________________________________________________________________________________
                           3. CONSTRUCCIÓN DE LA VARIABLE DE INFORMALIDAD
____________________________________________________________________________________________________


      Seguimos la definición del DANE que combina dos dimensiones:
     
      Dimensión 1 — Sector informal: empresa sin registro o sin contabilidad,
                  o empresa de hasta 5 trabajadores (P3069 <= 5 aprox.)
      Dimensión 2 — Ocupación informal: no cotiza pensión, trabajador familiar
                  sin remuneración, sin contrato, etc.

-------------------------------------- Dimensión 1: Sector informal ---------------------------------

 Una persona está en el sector informal si:

   a) Trabaja en empresa que NO tiene registro mercantil (P3045S1==2 para 
      asalariados, o P3065==2 / P3067==2 para independientes)

   b) La empresa NO lleva contabilidad (P3046==2 asalariados, P3066==2 / 
      P6775==2 independientes)

   c) No se pueden separar gastos del hogar y negocio (P3068==2)

   d) Empresa de 1 a 5 personas (P3069 <= 5, ó P3069 in {1,2,3,4,5})

    * Proxy por tamaño: En la GEIH nueva, P3069 tiene categorías donde los valores 1-5 representan diferentes
                        rangos pequeños.

         1=Trab. solo, 2=2-3, 3=4-5, 4=6-10, 5=11-19...
*/

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

/* 
-------------------------------------- Dimensión 1: Sector informal ---------------------------------------

        Informal si: no cotiza a pensión, o es trabajador familiar sin remuneración,
        o no tiene contrato, o cotiza a régimen subsidiado.
*/ 

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

* --------------------------- Variable Final: Informal (Si cumple ambas dimensiones) ----------------------

* Según DANE: la convergencia de sector informal Y ocupación informal
gen informal = (sector_informal == 1 & ocup_informal == 1)
replace informal = . if P6430 == .  // missing si no tiene posición ocupacional

* Pero hay casos especiales que siempre son informales:
* Donde trabajadores familiares sin remuneración siempre son informales
replace informal = 1 if inlist(P6430, 6, 7)

* Jornaleros/peones sin pensión
replace informal = 1 if P6430 == 8 & P6920 == 2

label variable informal "Informal (def. DANE: sector ∩ ocupación)"
label define linf 0 "Formal" 1 "Informal"
label values informal linf

* Tabla de población que cumple ambas | Con pesos
tab informal [iw=FEX_C18], m

/*
____________________________________________________________________________________________________
                           4. VARIABLES DERIVADAS ADICIONALES
_____________________________________________________________________________________________________
*/

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

/*
____________________________________________________________________________________________________
                     5. TASA DE INFORMALIDAD POR TRIMESTRE (verificación rápida)
_____________________________________________________________________________________________________

Tras detectar que la tasa inicial de informalidad se ubicaba alrededor del 53%, se ajustó el 
algoritmo de clasificación para incorporar correctamente a los trabajadores familiares sin remuneración 
y otras categorías ocupacionales estructuralmente informales.

Luego de esta corrección, la tasa estimada convergió hacia valores cercanos a las cifras oficiales 
reportadas por el DANE (~58%), lo que respalda la consistencia metodológica de la base construida.

*/

tab informal [iw=FEX_C18]
mean informal [pw=FEX_C18]

*/

* Unión de módulos (Ocupados + Características Generales)

merge 1:1 DIRECTORIO SECUENCIA_P ORDEN HOGAR using "caracteristicas_generales.dta"
keep if _merge == 3

* La construcción del indicador de informalidad
* Se aplicó la metodología de convergencia del DANE cruzando dos dimensiones:

gen informal = .
replace informal = 1 if (sector_informal == 1 & ocupacion_informal == 1)
replace informal = 0 if (sector_informal == 0 & ocupacion_informal == 0)

* Exclusión de empleados oficiales
replace informal = 0 if P6430 == 1

/*
______________________________________________________________________________________________________
                                                6. BASE FINAL
______________________________________________________________________________________________________
*/
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

/*
_____________________________________________________________________________________________________
                                    7. Delimitación de Variables
_____________________________________________________________________________________________________
*/

/*
_____________________________________________________________________________________________________
                                        8. Modelo de Regresión
_____________________________________________________________________________________________________


* -----------------------------  Estimación del modelo principal ------------------------------------

   Siguiendo la especificación de Sánchez Bárcenas et al. (2018), ecuación (6):
   
   P(informal_i = 1|X) = 1 / [1 + exp(-Z_i)]
   
   donde:
   Z_i = β0 + β1·mujer_i + β2·edad_i + β3·con_pareja_i + 
         β4·nivel_educ_i + β5·ingreso_mill_i + ε_i
         
   Variable dependiente: informal (1=Informal, 0=Formal)

* Crear limite de iteraciones
set maxiter 10
set iter 5

(1)* 8.0 Verificar/Crear variable con_pareja

cap drop con_pareja
gen con_pareja = 0
replace con_pareja = 1 if inlist(P6070, 1, 2)  // 1=Casado, 2=Unión libre
label variable con_pareja "Tiene pareja"
label define lpareja 0 "Sin pareja" 1 "Con pareja"
label values con_pareja lpareja

(2)* 8.0.1 Verificar/Crear ingreso_mill
cap drop ingreso_mill
gen ingreso_mill = ingreso / 1000000
label variable ingreso_mill "Ingreso laboral (millones COP)"

* 8.0.2 Verificar que nivel_educ es numérica (ya debería estarlo)
cap confirm numeric variable nivel_educ
if _rc == 0 {
    di "✓ nivel_educ es numérica - correcto"
}
else {
    di "ERROR: nivel_educ no es numérica"
}

* 8.1  Modelo con pesos
logit informal mujer edad con_pareja nivel_educ ingreso_mill [pweight=FEX_C18]

(3)* 8.1.1 Modelo con factores de expansión (pweight) - USANDO P6040 (edad)
logit informal mujer P6040 con_pareja i.nivel_educ ingreso_mill [pweight=FEX_C18], vce(robust)

* Odds ratios

logit, or
logit informal mujer edad con_pareja nivel_educ ingreso_mill [pweight=FEX_C18], or

**** En ejecución del modelo se presentan mas  de 100 iteraciones, sin embargo se puede acotar la cantidad
de repeticiones con el fin de ajustarlo

* Opción 1: Reducir la tolerancia (menos preciso, más rápido)
logit informal mujer P6040 con_pareja i.nivel_educ ingreso_mill [pw=FEX_C18], vce(robust) tolerance(1e-6)

* Opción 2: Aumentar iteraciones pero mostrar menos log
set iterlog off      * No muestra cada iteración
set maxiter 100      * Máximo 100 iteraciones

* Opción 3: Lo más rápido - sin errores robustos (no recomendado para trabajo académico)
logit informal mujer P6040 con_pareja i.nivel_educ ingreso_mill [pw=FEX_C18]  ****

* ---------------------------------- Pruebas Bondad de Ajuste ---------------------------------------

* Los diagnósticos clásicos no aceptan pweight, así que retiramos los pesos

describe informal mujer P6040 con_pareja nivel_educ ingreso_mill
logit informal mujer P6040 con_pareja i.nivel_educ ingreso_mill

* Matriz de clasificación (¿Qué tan bien predice el modelo?)

estat classification

* 8.1 Curva ROC (Poder de discriminación del modelo)

quietly logit informal mujer P6040 con_pareja i.nivel_educ ingreso_mill
lroc, title("Curva ROC - Modelo Logit")


* 8.2 AIC, BIC y Pseudo R^2
estat ic

* 8.2.5 Test de Hosmer-Lemeshow
estat gof, group(10)

* 8.3 linktest (forma funcional)
linktest

===================== PRUEBAS DE SUPUESTOS ====================="

* 8.4.1 VIF (multicolinealidad)
quietly regress informal mujer edad con_pareja i.nivel_educ ingreso_mill
estat vif

* 8.4.2 Test de linealidad (relación no lineal de edad)
gen edad2 = edad^2
quietly logit informal mujer edad edad2 con_pareja i.nivel_educ ingreso_mill
test edad edad2
di "Test de relación no lineal (H0: relación lineal):"
di "   p-valor = " %5.4f r(p)
if r(p) < 0.05 {
    di "   → Relación NO lineal detectada"
}
else {
    di "   → Relación lineal aceptada"
}

* 8.4.3 VIF (colinealidad) con OLS auxiliar

quietly regress informal mujer edad con_pareja nivel_educ ingreso_mill
estat vif


*-----------------------------   Efectos marginales (resultados preliminares) --------------------------

quietly logit informal mujer edad con_pareja nivel_educ ingreso_mill [pweight=FEX_C18]

* Efectos marginales promedio (AME)
margins, dydx(mujer edad con_pareja nivel_educ ingreso_mill)

* Gráfico de AMEs
marginsplot, horizontal recast(scatter) ///
    title("Efectos marginales promedio sobre P(informal)") ///
    xline(0) graphregion(color(white))
graph export "$ruta/figuras/g_AME.png", replace width(1400)

* Probabilidad predicha por nivel educativo (otras X en su media)
margins, at(nivel_educ=(1(1)7))
marginsplot, ///
    title("Probabilidad predicha de informalidad por nivel educativo") ///
    ytitle("P(informal)") xtitle("Nivel educativo") ///
    graphregion(color(white))
graph export "$ruta/figuras/g_margins_educ.png", replace width(1400)

* Probabilidad predicha por ingreso
margins, at(ingreso_mill=(0(0.5)5))
marginsplot, ///
    title("Probabilidad predicha de informalidad por ingreso") ///
    ytitle("P(informal)") xtitle("Ingreso laboral (millones COP)") ///
    graphregion(color(white))
graph export "$ruta/figuras/g_margins_ingreso.png", replace width(1400)


di "Base guardada: `c(N)' observaciones, `c(k)' variables"
di "Período: 2022Q1 - 2025Q4 (16 trimestres)"


/* ------------------------------------- Interpretaciones:------------------------------------------
   
   1. Interpretación de 'mujer': Si el dydx es XXXX, significa que ser mujer aumenta 
      en XXX puntos porcentuales la probabilidad de ser informal, ceteris paribus.
   
   2. Educación: Los coeficientes XXXXX en niveles altos (Posgrado) confirman 
      que la educación es un escudo contra la informalidad.
   
   3. Ingreso: El coeficiente de 'ln_ingreso' debería ser negativo y significativo.

*/

*/ ________________________________________________________________________________________________
                                        9. Tablas y Gráficos
_____________________________________________________________________________________________________
*/


/*
_____________________________________________________________________________________________________
                                    10. Intepretaciones y Resultados
_____________________________________________________________________________________________________
*/

/*
_____________________________________________________________________________________________________
                                          11. Conclusiones
_____________________________________________________________________________________________________
*/

