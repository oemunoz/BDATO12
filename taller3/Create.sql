CREATE TABLE pelicula(
  id NUMBER(8) PRIMARY KEY,
  titulo VARCHAR(80) UNIQUE NOT NULL);

CREATE TABLE cinema(
	id NUMBER(8) PRIMARY KEY,
	salas XMLTYPE NOT NULL,
  programacion XMLTYPE NOT NULL,
	cartelera XMLTYPE NOT NULL,
	criticos XMLTYPE);

---  SELECT       table_name FROM user_tables;
---  desc PELICULA;
---  desc CINEMA;
