# TALLER BASES DE DATOS
Construya un procedimiento PL/SQL para los siguientes ejercicios:

### Solution by:
Oscar Ernesto Muñoz
## Definicion de tablas

``` sql
CREATE TABLE pelicula(
  id NUMBER(8) PRIMARY KEY,
  titulo VARCHAR(80) UNIQUE NOT NULL);

CREATE TABLE cinema(
	id NUMBER(8) PRIMARY KEY,
	salas XMLTYPE NOT NULL,
  programacion XMLTYPE NOT NULL,
	cartelera XMLTYPE NOT NULL,
	criticos XMLTYPE);
```

## Poblar con un dato la tabla

``` sql
INSERT INTO cinema
  VALUES(102,
  XMLType('<salas>
                      	<sala>
                      		<numero>1</numero>
                      		<formato>2D</formato>
                      	</sala>
                      	<sala>
                      		<numero>2</numero>
                      		<formato>3D</formato>
                      	</sala>
                      	<sala>
                      		<numero>3</numero>
                      		<formato>4D</formato>
                      	</sala>
                      	<sala>
                      		<numero>4</numero>
                      		<formato>vibrosound</formato>
                      	</sala>
                      </salas>
                      '),
  XMLType('<programacion>
          	<funcion>
          		<codigo>1</codigo>
          		<horainicio>13:00</horainicio>
          		<horafinal>15:00</horafinal>
          		<fecha>10/feb/2016</fecha>
          		<pelicula>1</pelicula>
          		<sala>1</sala>
          		<formato>2D</formato>
          	</funcion>
          	<funcion>
          		<codigo>2</codigo>
          		<horainicio>15:30</horainicio>
          		<horafinal>17:30</horafinal>
          		<fecha>10/feb/2016</fecha>
          		<pelicula>2</pelicula>
          		<sala>1</sala>
          		<formato>2D</formato>
          	</funcion>
            <funcion>
          		<codigo>3</codigo>
          		<horainicio>15:30</horainicio>
          		<horafinal>17:30</horafinal>
          		<fecha>12/feb/2016</fecha>
          		<pelicula>3</pelicula>
          		<sala>1</sala>
          		<formato>3D</formato>
          	</funcion>
          </programacion>'),
  XMLType('<cartelera>
  	<pelicula>
  		<codigo>1</codigo>
  		<titulo>Deadpool</titulo>
  		<duracion>106</duracion>
  		<generos>
  			<genero>comedia</genero>
  			<genero>aventura</genero>
  		</generos>
  	</pelicula>
  	<pelicula>
  		<codigo>2</codigo>
  		<titulo>Alvin y las ardillas</titulo>
  		<duracion>102</duracion>
  		<generos>
  			<genero>aventura</genero>
  			<genero>accion</genero>
  		</generos>
  	</pelicula>
    <pelicula>
      <codigo>3</codigo>
      <titulo>Caperusita comiendo con el lobo feroz</titulo>
      <duracion>0</duracion>
      <generos>
        <genero>porno</genero>
        <genero>accion</genero>
      </generos>
    </pelicula>
  </cartelera>
  '),
  ''
  );
```


## Ejercicios

1. Verificar que en una función no se programe una película en un formato que no sea soportado por la respetiva sala donde está programada.
2. Verificar que la duración de una película sea un número entero mayor que cero.
3. Verificar que el tiempo que dura cada función sea mayor al de la duración de la película que tiene programada, el excedente de tiempo (si lo hay) es para proyectar avances (trailers) de otras películas y no puede ser superior a 20 minutos.

## Solucion

``` sql
SET SERVEROUTPUT ON
DECLARE

-- Declare collection type to bulk load into.
type sala_rt is record (
  sala_numero        number,
  sala_formato       varchar2(255)
);

type sala_tt is table of sala_rt;
salaTable       sala_tt;
salaRecord      sala_rt;

-- Declare collection type to bulk load into.
type funcion_rt is record (
  funcion_codigo        number,
  funcion_sala          number,
  funcion_pelicula      number,
  funcion_formato              varchar2(255),
  funcion_horainicio           varchar2(5),
  funcion_horafinal            varchar2(5),
  funcion_fecha                varchar2(11)
  --formato5           varchar2(255)
);

type funcion_tt is table of funcion_rt;
funcionTable       funcion_tt;
funcionRecord      funcion_rt;

i_date   DATE;
f_date   DATE;
diference_min number;

-- Declare collection type to bulk load into.
type pelicula_rt is record (
  pelicula_codigo       number,
  pelicula_titulo       varchar2(255),
  pelicula_duracion     number
);

type pelicula_tt is table of pelicula_rt;
peliculaTable       pelicula_tt;
peliculaRecord      pelicula_rt;

BEGIN
  dbms_output.put_line('Bases de datos II taller 3.');
  -- Bulk load the sala collection based on the xml.
  select  extractValue( value( ci ), '*/numero' ) sala_numero,
          extractValue( value( ci ), '*/formato' ) sala_formato bulk collect into salaTable from cinema c, table( XMLSequence(
    extract(salas, '/salas/sala') ) ) ci WHERE id=102;

  --- Bulk load the funcion collection based on the xml.
  select  extractValue( value( ci ), '*/codigo' ) funcion_codigo,
          extractValue( value( ci ), '*/sala' ) funcion_sala,
          extractValue( value( ci ), '*/pelicula' ) funcion_pelicula,
          extractValue( value( ci ), '*/formato' ) funcion_formato,
          extractValue( value( ci ), '*/horainicio' ) funcion_horainicio,
          extractValue( value( ci ), '*/horafinal' ) funcion_horafinal,
          extractValue( value( ci ), '*/fecha' ) funcion_fecha bulk collect into funcionTable from cinema c, table( XMLSequence(
    extract(programacion, '/programacion/funcion') ) ) ci WHERE id=102;

--- Bulk load the pelicula collection based on the xml.
  select  extractValue( value( ci ), '*/codigo' )   pelicula_codigo,
          extractValue( value( ci ), '*/titulo' )   pelicula_titulo,
          extractValue( value( ci ), '*/duracion' ) pelicula_duracion bulk collect into peliculaTable from cinema c, table( XMLSequence(
    extract(cartelera, '/cartelera/pelicula') ) ) ci WHERE id=102;

  -- Loop through sala collection to display results.
  if funcionTable.count > 0 then
    for i in funcionTable.FIRST..funcionTable.LAST loop
      funcionRecord := funcionTable( i );
      --dbms_output.put_line( '::: Funcion :::');
      --dbms_output.put_line( 'Codigo: ' || funcionRecord.funcion_codigo || ' :Sala: ' || funcionRecord.funcion_sala || ' :Formato: ' || funcionRecord.funcion_formato);
      if salaTable.count > 0 then
        for j in salaTable.FIRST..salaTable.LAST loop
          salaRecord := salaTable( j );
          --- Check salas.
          if funcionRecord.funcion_sala = salaRecord.sala_numero then
            if funcionRecord.funcion_formato <> salaRecord.sala_formato then
              dbms_output.put_line( '::: Primer punto ::: Codigo de funcion: ' || funcionRecord.funcion_codigo);
              dbms_output.put_line( 'Numero de sala (funcion): ' || funcionRecord.funcion_sala || ': Sala numero (sala): ' || salaRecord.sala_numero);
              dbms_output.put_line( 'Formato de sala (funcion): ' || funcionRecord.funcion_formato || ': Sala Formato (sala): ' || salaRecord.sala_formato);
            end if;
          end if;
        end loop;
      end if;
    end loop;
  end if;

  -- Loop through pelicula collection to check the value movie duration.
  if peliculaTable.count > 0 then
    for i in peliculaTable.FIRST..peliculaTable.LAST loop
      peliculaRecord := peliculaTable( i );
      if NOT(peliculaRecord.pelicula_duracion > 0) then
        dbms_output.put_line( '::: Segundo punto ::: La pelicula con codigo no clumple la condicion: ' || peliculaRecord.pelicula_codigo || ' titulo: ' || peliculaRecord.pelicula_titulo);
      --else
        --dbms_output.put_line( '::: Tercer punto ::: Verificacion de duracion de funciones: ' );
      end if;
    end loop;
  end if;

  -- Loop through funtion collection to compare the duration.
  if funcionTable.count > 0 then
    for i in funcionTable.FIRST..funcionTable.LAST loop
      funcionRecord := funcionTable( i );
      if peliculaTable.count > 0 then
        for j in peliculaTable.FIRST..peliculaTable.LAST loop
          peliculaRecord := peliculaTable( j );
          if peliculaRecord.pelicula_codigo = funcionRecord.funcion_pelicula then
            i_date := TO_DATE(  funcionRecord.funcion_fecha|| ' ' || funcionRecord.funcion_horainicio, 'dd/MON/yyyy HH24:MI');
            f_date := TO_DATE(  funcionRecord.funcion_fecha|| ' ' || funcionRecord.funcion_horafinal, 'dd/MON/yyyy HH24:MI');
            diference_min := (f_date - i_date) * 24 * 60;
            if diference_min < peliculaRecord.pelicula_duracion then
              dbms_output.put_line( '::: Tercer punto ::: El tiempo de duracion de la peli excede el tiempo de duracion de la funcion.: ');
            elsif diference_min - peliculaRecord.pelicula_duracion > 20 then
              dbms_output.put_line( '::: Tercer punto ::: Demasiado tiempo sobrante en la funcion con codigo: '|| funcionRecord.funcion_codigo) ;
            end if;
          end if;
        end loop;
      end if;
    end loop;
  end if;

END;
/
-- quit;
--@/u01/app/oracle/Scripts/taller3/taller.pls
```

### 160421: First data.
Second window:
"Taller 3 de BD II."
![Salida taller.](images/OutputTaller.png)

## License

The source is under terms of the MIT license.
