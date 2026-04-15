////////////////////////////////////////
///////Análisis ECV menores 5 años//////
///////////////////////////////////////

//*1. Set up del do file/////

clear all
set mem 2g
set more off

**LOG FILE
*habilitar el log
cd "G:\Mi unidad\Proyecto_x\datos\log"
log using "limpieza_atencion_nn_5anos", replace

*para apagar temporalmente el log
log off
log on


/*NOTAS COMANDOS AYUDA
1- comando ayuda sobre un comando
help 
2- ayuda con palabra clave
search
3- ampliar busqueda a internet
findit
4- intalar un comando
ssc install *opcion , replace para actualizar*/

///*2. Explorar un conjunto de datos////

*Abrir datos menores de 5 años ECV 2023
*abir desde .dta
cd "G:\Mi unidad\Proyecto_x\datos\raw\atencion_menores5anos_2023"
use "Atención integral de los niños y niñas menores de 5 años.dta"

/*abrir desde .cvs
cd "G:\Mi unidad\Proyecto_x\datos\raw\atencion_menores5anos_2023"
import delimited "Atención integral de los niños y niñas menores de 5 años.CSV", delimiter(";") clear 
*/

*exploración del conjunto de datos
*lista de variables
describe
*estadisticas descriptivas
summarize
summarize P51, d
*valores que toma una variable
tab P772


//////*3. Limpieza de datos//////////////
*Obj: limpiar conjunto de datos menores de 5 años

/*3.1 NOTAS SOBRE FORMATO
*NOTA: para cambiar formato númerico: format %8.0gc P6169S1*/
*NOTA: reducir el tamaño de una variable o de la base en general
compress

*NOTA: volver una numerica variable string
-remplazando
tostring DIRECTORIO, replace
-generando variable nueva
tostring SECUENCIA_ENCUESTA, gen(SECUENCIA_ENCUESTA2)

*NOTA: volver una variable sting numerica
 destring P51, replace

/*3.2 NOTAS ASIGNAR ETIQUETAS*/ 
*Solo aparecen en las tablas y gráficas ! Más recomendado
*Etiqueta base de datos
label data "Menores 5 años" 
*Etiqueta para la variable
label var P51 "cuidado entre semana"
*Etiqueta para los valores de la variable
label define cuidadoentresemana 1 "Hogar jardin" ///
2 "Padres en casa" 3 "Padres fuera de casa" ///
4 "Empleado en casa" 5 "Familiar mayor de 18" ///
6 "Familiar menor de 18" 8 "Otro"
label values P51 cuidadoentresemana

/*3.3 Renombrar variables*/
*Cambia el nombre de la variable
rename P51 "cuidado entre semana"
*generar una variable que identifique el año

/*3.4 Generar variables*/
*Generar una variable vacia
*si string 
gen var_string=""
*si numerica
gen var_numerica=.

*Es posible usar expresiones matemáticas y lógicas

*Una variable puede generarse en función de otra
gen cuidado_familia=0
replace cuidado_familia=1 if P51==2 | P51==3 | P51==5 | P51==6 
tab P51 cuidado_familia


**!! Importante generar variables año y mes para identificar las bases del DANE
*Para la ECV 2023
gen anno=2023


/*3.5 Ejemplo substring*/
tostring DIRECTORIO, gen(directorio)
gen direc= substr(directorio,1,2)
br DIRECTORIO directorio direc


/*3.6 Borrar variables*/
*borra variables de la base o creadas
drop cuidado_familia direc var_string var_numerica directorio
***

*cerrar el archivo*/

log close

cd "G:\Mi unidad\Proyecto_x\datos\limpios"
save "nn5anos_2023.dta", replace




