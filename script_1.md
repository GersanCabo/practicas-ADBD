1. Creación de la base de datos

	1.1. Crear una base de datos llamada biblioteca.

	```sql
		CREATE DATABASE biblioteca;
		/c biblioteca
	```

	```
															List of databases
		Name    |  Owner   | Encoding | Locale Provider |   Collate   |    Ctype    | ICU Locale | ICU Rules |     Access privileges     
	------------+----------+----------+-----------------+-------------+-------------+------------+-----------+---------------------------
	 biblioteca | postgres | UTF8     | libc            | es_ES.UTF-8 | es_ES.UTF-8 |            |           | =Tc/postgres             +
				|          |          |                 |             |             |            |           | postgres=CTc/postgres    +
				|          |          |                 |             |             |            |           | admin_biblio=CTc/postgres
	```

2. Creación de usuarios

	2.1. Crear dos usuarios
	
	* **admin_biblio** con permisos de administrador sobre la base de datos.
	* **usuario_biblio** con permisos solo de lectura.

	```sql
	CREATE ROLE admin_biblio WITH LOGIN PASSWORD 'adminpass';
	CREATE ROLE usuario_biblio WITH LOGIN PASSWORD 'usuariopass';
	
	GRANT ALL PRIVILEGES ON DATABASE biblioteca TO admin_biblio;
	GRANT ALL PRIVILEGES ON SCHEMA public TO admin_biblio;

	--- Conectar a la base de datos y usar el esquema
	GRANT CONNECT ON DATABASE biblioteca TO usuario_biblio;
	GRANT USAGE ON SCHEMA public TO usuario_biblio;
	--- Sólo lectura en todas las tablas
	GRANT SELECT ON ALL TABLES IN SCHEMA public TO usuario_biblio;
	```

	```
									List of roles
	Role name      | Attributes                         
	---------------+------------------------------------------------------------
	admin_biblio   | 
	postgres       | Superuser, Create role, Create DB, Replication, Bypass RLS
	usuario_biblio | 
	```

	2.2. Crear un rol llamado lectores con permisos únicamente de consulta sobre todas las tablas de la base de datos.

	```sql
	CREATE ROLE lectores NOLOGIN;
	GRANT SELECT ON ALL TABLES IN SCHEMA public TO lectores;
	```

	```
	                                List of roles
	Role name      | Attributes                         
	---------------+------------------------------------------------------------
	admin_biblio   | 
	lectores       | Cannot login
	postgres       | Superuser, Create role, Create DB, Replication, Bypass RLS
	usuario_biblio |
	```

	2.3. Asignar el usuario usuario_biblio a este rol.

	```sql
	GRANT lectores TO usuario_biblio;
	```

	2.4. Consultar las tablas del sistema para listar todos los usuarios creados (pg_roles).

	```sql
	SELECT rolname, rolsuper, rolcreaterole, rolcreatedb, rolcanlogin FROM pg_roles ORDER BY rolname;
	```

	```
			rolname           | rolsuper | rolcreaterole | rolcreatedb | rolcanlogin 
	-----------------------------+----------+---------------+-------------+-------------
	admin_biblio                | f        | f             | f           | t
	lectores                    | f        | f             | f           | f
	pg_checkpoint               | f        | f             | f           | f
	...
	pg_write_server_files       | f        | f             | f           | f
	postgres                    | t        | t             | t           | t
	usuario_biblio              | f        | f             | f           | t
	```

	2.5. Cambiar la contraseña del usuario usuario_biblio.

	```sql
	ALTER ROLE usuario_biblio WITH PASSWORD '1234';
	```

	2.6. Configurar permisos de tal forma que el usuario usuario_biblio no pueda eliminar registros en ninguna tabla.

	```sql
	REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM usuario_biblio;
	```

	```psql -U usuario_biblio -d biblioteca -h localhost```

	```
	biblioteca=> DELETE FROM autores WHERE id_autor=1
	biblioteca-> ;
	ERROR:  permission denied for table autores
	```

3. Creación de tablas 

	3.1. Crear las siguientes tablas con sus respectivas claves primarias:
    
   * autores(id_autor, nombre, nacionalidad)

	```sql
	CREATE TABLE autores(
	id_autor SERIAL PRIMARY KEY,
	nombre TEXT NOT NULL,
	nacionalidad TEXT
	);
	```

   * libros(id_libro, titulo, año_publicacion, id_autor)

		Añadimos la clave foranea más adelante con ALTER TABLE.

	```sql
	CREATE TABLE libros(
	id_libro SERIAL PRIMARY KEY,
	titulo TEXT NOT NULL,
	ano_publicacion INT,
	id_autor INT
	);
	```

   * prestamos(id_prestamo, id_libro, fecha_prestamo, fecha_devolucion, usuario_prestatario)

	```sql
	CREATE TABLE prestamos(
	id_prestamo SERIAL PRIMARY KEY,
	id_libro INT,
	fecha_prestamo DATE,
	fecha_devolucion DATE,
	usuario_prestatario TEXT NOT NULL
	);
	```
	
	Resultados de crear estas tres tablas:
	```
	List of relations
	Schema |   Name    | Type  |  Owner   
	-------+-----------+-------+----------
	public | autores   | table | postgres
	public | libros    | table | postgres
	public | prestamos | table | postgres
	```

	3.2. Establecer las claves foráneas correspondientes

	Modificamos los atributos de la tabla para añadir la clave foranea, dandole nombre a la restricción con CONSTRAINT, señalando con FOREIGN KEY el atributo que queremos que sea una clave foranea y utilizando REFERENCES para señalar el atributo correspondiente de la tabla autores.

	```sql
	ALTER TABLE libros
	ADD CONSTRAINT fk_id_autor
	FOREIGN KEY (id_autor)
	REFERENCES autores(id_autor);
	```

	```sql
	ALTER TABLE prestamos
	ADD CONSTRAINT fk_id_libro
	FOREIGN KEY (id_libro)
	REFERENCES libros(id_libro)
	ON DELETE CASCADE;
	```

4. Inserción de datos
   
   4.1. Insertar al menos 5 autores, 8 libros y 5 prestamos de ejemplo. 

	Los atributos SERIAL se autoincrementan automáticamente, por lo que no es necesario especificarlos al insertar datos.

	```sql
	INSERT INTO autores (nombre, nacionalidad) VALUES ('Miguel de Cervantes Saavedra', 'Española');
	INSERT INTO autores (nombre, nacionalidad) VALUES ('Jane Austen', 'Británica');
	INSERT INTO autores (nombre, nacionalidad) VALUES ('Jorge Luis Borges', 'Argentina');
	INSERT INTO autores (nombre, nacionalidad) VALUES ('Haruki Murakami', 'Japonesa');
	INSERT INTO autores (nombre, nacionalidad) VALUES ('Virginia Woolf', 'Británica');
	```
	
	```
	 id_autor |            nombre            | nacionalidad 
	----------+------------------------------+--------------
			1 | Miguel de Cervantes Saavedra | Española
			2 | Jane Austen                  | Británica
			3 | Jorge Luis Borges            | Argentina
			4 | Haruki Murakami              | Japonesa
			5 | Virginia Woolf               | Británica
	```

	```sql
	INSERT INTO libros (titulo, ano_publicacion, id_autor) VALUES ('Don Quijote de la Mancha', '1615', 1);
	INSERT INTO libros (titulo, ano_publicacion, id_autor) VALUES ('Novelas ejemplares', '1613', 1);
	INSERT INTO libros (titulo, ano_publicacion, id_autor) VALUES ('Orgullo y prejuicio', '1813', 2);
	INSERT INTO libros (titulo, ano_publicacion, id_autor) VALUES ('Sensatez y sentimientos', '1811', 2);
	INSERT INTO libros (titulo, ano_publicacion, id_autor) VALUES ('Ficciones', '1944', 3);
	INSERT INTO libros (titulo, ano_publicacion, id_autor) VALUES ('El Aleph', '1949', 3);
	INSERT INTO libros (titulo, ano_publicacion, id_autor) VALUES ('Tokio blues (Norwegian Wood)', '1987', 4);
	INSERT INTO libros (titulo, ano_publicacion, id_autor) VALUES ('La señora Dalloway', '1925', 5);
	```

	```
	 id_libro |            titulo            | ano_publicacion | id_autor 
	----------+------------------------------+-----------------+----------
			1 | Don Quijote de la Mancha     |            1615 |        1
			2 | Novelas ejemplares           |            1613 |        1
			3 | Orgullo y prejuicio          |            1813 |        2
			4 | Sensatez y sentimientos      |            1811 |        2
			5 | Ficciones                    |            1944 |        3
			6 | El Aleph                     |            1949 |        3
			7 | Tokio blues (Norwegian Wood) |            1987 |        4
			8 | La señora Dalloway           |            1925 |        5
	```

	```sql
	INSERT INTO prestamos (id_libro, fecha_prestamo, fecha_devolucion, usuario_prestatario) VALUES (1, '2026-09-20', '2026-09-29', 'Dónovan Martín Hernández');
	INSERT INTO prestamos (id_libro, fecha_prestamo, fecha_devolucion, usuario_prestatario) VALUES (2, '2026-09-21', '2026-10-01', 'Gersán Cabo del Pino');
	INSERT INTO prestamos (id_libro, fecha_prestamo, fecha_devolucion, usuario_prestatario) VALUES (3, '2026-09-22', null, 'Pavel Novoa Hernández');
	INSERT INTO prestamos (id_libro, fecha_prestamo, fecha_devolucion, usuario_prestatario) VALUES (5, '2026-09-23', '2026-10-05', 'Pavel Novoa Hernández');
	INSERT INTO prestamos (id_libro, fecha_prestamo, fecha_devolucion, usuario_prestatario)	VALUES (7, '2026-09-24', null, 'David Fernández Torres');
	```

	```
	 id_prestamo | id_libro | fecha_prestamo | fecha_devolucion |   usuario_prestatario    
	-------------+----------+----------------+------------------+--------------------------
			   1 |        1 | 2026-09-20     | 2026-09-29       | Dónovan Martín Hernández
			   2 |        2 | 2026-09-21     | 2026-10-01       | Gersán Cabo del Pino
			   3 |        3 | 2026-09-22     | null  			      | Pavel Novoa Hernández
			   4 |        5 | 2026-09-23     | 2026-10-05       | Pavel Novoa Hernández
			   5 |        7 | 2026-09-24     | 2026-10-08       | David Fernández Torres

	```

5. Consultas básicas
	
	5.1. Listar todos los libros con su autor correspondiente.

	```sql
	SELECT libros.titulo, autores.nombre AS autor
	FROM libros
	JOIN autores ON libros.id_autor = autores.id_autor;
	```

	```
	            titulo            |            autor             
	------------------------------+------------------------------
	Don Quijote de la Mancha      | Miguel de Cervantes Saavedra
	Novelas ejemplares            | Miguel de Cervantes Saavedra
	Orgullo y prejuicio           | Jane Austen
	Sensatez y sentimientos       | Jane Austen
	Ficciones                     | Jorge Luis Borges
	El Aleph                      | Jorge Luis Borges
	Tokio blues (Norwegian Wood)  | Haruki Murakami
	La señora Dalloway            | Virginia Woolf
	```

	5.2. Mostrar los préstamos que aún no tienen fecha de devolución.

	```sql
	SELECT *
	FROM prestamos
	WHERE fecha_devolucion IS NULL;
	```

	```
	id_prestamo | id_libro | fecha_prestamo | fecha_devolucion |  usuario_prestatario   
	------------+----------+----------------+------------------+------------------------
			  3 |        3 | 2026-09-22     |                  | Pavel Novoa Hernández
			  5 |        7 | 2026-09-24     |                  | David Fernández Torres
	```
	
	5.3. Obtener los autores que tienen más de un libro registrado.
	
	```sql
	SELECT a.nombre, COUNT(l.id_libro) AS cantidad_libros
	FROM autores a
	JOIN libros l ON a.id_autor = l.id_autor
	GROUP BY a.id_autor, a.nombre
	HAVING COUNT(l.id_libro) > 1;
	```

	```
	            nombre           | cantidad_libros 
	-----------------------------+-----------------
	Jane Austen                  |               2
	Jorge Luis Borges            |               2
	Miguel de Cervantes Saavedra |               2
	```

6. Consultas con agregación



	6.1. Calcular el número total de préstamos realizados.
	
	```sql
	SELECT COUNT(*) AS total_prestamos
	FROM prestamos;
	```

	```
	 total_prestamos 
	-----------------
            5
	```

	6.2. Obtener el número de libros prestados por cada usuario.

	```sql
	SELECT usuario_prestatario, COUNT(*) AS cantidad_prestamos
	FROM prestamos
	GROUP BY usuario_prestatario;
	```

	```
	usuario_prestatario       | cantidad_prestamos 
	--------------------------+--------------------
	Dónovan Martín Hernández  | 1
	Pavel Novoa Hernández     | 2
	Gersán Cabo del Pino      | 1
	David Fernández Torres    | 1
	```

7. Modificación de datos
	
	7.1. Actualizar la fecha de devolución de un préstamo pendiente.
	
	```sql
	UPDATE prestamos
	SET fecha_devolucion = '2026-10-10'
	WHERE id_prestamo = 3;
	```

	```
	 id_prestamo | id_libro | fecha_prestamo | fecha_devolucion |   usuario_prestatario    
	-------------+----------+----------------+------------------+--------------------------
			   1 |        1 | 2026-09-20     | 2026-09-29       | Dónovan Martín Hernández
		       2 |        2 | 2026-09-21     | 2026-10-01       | Gersán Cabo del Pino
			   4 |        5 | 2026-09-23     | 2026-10-05       | Pavel Novoa Hernández
			   5 |        7 | 2026-09-24     |                  | David Fernández Torres
			   3 |        3 | 2026-09-22     | 2026-10-10       | Pavel Novoa Hernández
	```
	
	7.2. Eliminar un libro y comprobar el efecto en la tabla de préstamos (usar ON DELETE CASCADE o justificar el comportamiento).

	Al eliminar el libro de la tabla libros, PostgreSQL borrará automáticamente todos los registros de la tabla prestamos que estuvieran asociados a ese id_libro si al definir la FK utilizamos ON DELETE CASCADE.

	```sql
	DELETE FROM libros WHERE id_libro = 3;
	```

8. Creación de vistas
  
	8.1. Crear una vista llamada vista_libros_prestados que muestre: título del libro, autor y nombre del prestatario.

	```sql
	CREATE VIEW vista_libros_prestados AS
	SELECT l.titulo, a.nombre AS autor, p.usuario_prestatario
	FROM libros l
	JOIN autores a ON l.id_autor = a.id_autor
	JOIN prestamos p ON l.id_libro = p.id_libro;
	```

	```
				titulo            |            autor             |   usuario_prestatario    
	------------------------------+------------------------------+--------------------------
	Don Quijote de la Mancha      | Miguel de Cervantes Saavedra | Dónovan Martín Hernández
	Novelas ejemplares            | Miguel de Cervantes Saavedra | Gersán Cabo del Pino
	Ficciones                     | Jorge Luis Borges            | Pavel Novoa Hernández
	Tokio blues (Norwegian Wood)  | Haruki Murakami              | David Fernández Torres
	Orgullo y prejuicio           | Jane Austen                  | Pavel Novoa Hernández
	```
	
	8.2. Conceder permisos de consulta sobre esta vista únicamente a usuario_biblio.
	```sql
	GRANT SELECT ON vista_libros_prestados TO usuario_biblio;
	```

	```psql -U usuario_biblio -d biblioteca -h localhost```

	```
	biblioteca=> select * from vista_libros_prestados
	biblioteca-> ;
				titulo            |            autor             |   usuario_prestatario    
	------------------------------+------------------------------+--------------------------
	Don Quijote de la Mancha      | Miguel de Cervantes Saavedra | Dónovan Martín Hernández
	Novelas ejemplares            | Miguel de Cervantes Saavedra | Gersán Cabo del Pino
	Ficciones                     | Jorge Luis Borges            | Pavel Novoa Hernández
	Tokio blues (Norwegian Wood)  | Haruki Murakami              | David Fernández Torres
	Orgullo y prejuicio           | Jane Austen                  | Pavel Novoa Hernández
	```
	
	```psql -U otro_usuario -d biblioteca -h localhost```
  
9. Funciones y consultas avanzadas
	
	9.1. Crear una función que reciba el nombre de un autor y devuelva todos los libros escritos por él.
	
	```sql
	CREATE OR REPLACE FUNCTION obtener_libros_por_autor(nombre_autor TEXT)
	RETURNS TABLE(titulo TEXT, ano_publicacion INT) AS $$
	BEGIN
		RETURN QUERY
		SELECT l.titulo, l.ano_publicacion
		FROM libros l
		JOIN autores a ON l.id_autor = a.id_autor
		WHERE a.nombre = nombre_autor;
	END;
	$$ LANGUAGE plpgsql;
	```

	```sql
	SELECT * FROM obtener_libros_por_autor('Miguel de Cervantes Saavedra');
	```

	```
	          titulo          | ano_publicacion 
	--------------------------+-----------------
	Don Quijote de la Mancha  |            1615
	Novelas ejemplares        |            1613
	```

	9.2. Crear una consulta que devuelva los tres libros más prestados.
	```sql
	SELECT l.titulo, COUNT(p.id_prestamo) AS cantidad_prestamos
	FROM libros l
	JOIN prestamos p ON l.id_libro = p.id_libro
	GROUP BY l.id_libro, l.titulo
	ORDER BY cantidad_prestamos DESC
	LIMIT 3;
	```

	```
	       titulo        | cantidad_prestamos 
	---------------------+--------------------
	Orgullo y prejuicio  |                  2
	Novelas ejemplares   |                  1
	Ficciones            |                  1
	```

10. Exportación e importación de datos

	10.1. Exportar el contenido de la tabla libros a un archivo CSV.

	```
	\copy public.libros TO '/tmp/libros.csv' WITH (FORMAT csv, HEADER, DELIMITER ',');
	```

	```
	usuario@ubuntu:/tmp$ cat libros.csv 
	id_libro,titulo,ano_publicacion,id_autor
	1,Don Quijote de la Mancha,1615,1
	2,Novelas ejemplares,1613,1
	3,Orgullo y prejuicio,1813,2
	4,Sensatez y sentimientos,1811,2
	5,Ficciones,1944,3
	6,El Aleph,1949,3
	7,Tokio blues (Norwegian Wood),1987,4
	8,La señora Dalloway,1925,5
	```

	10.2. Importar datos adicionales de autores desde un archivo CSV externo.

	```
	nombre,nacionalidad
	Gabriel García Márquez,Colombiana
	Isabel Allende,Chilena
	Julio Cortázar,Argentina
	Mario Vargas Llosa,Peruana
	Laura Esquivel,Mexicana
	Carlos Fuentes,Mexicana
	Octavio Paz,Mexicana
	Alejandro Casona,Española
	Federico García Lorca,Española
	Benito Pérez Galdós,Española
	```

	```
	\copy public.autores (nombre, nacionalidad) FROM '/tmp/autores.csv' WITH (FORMAT csv, HEADER, DELIMITER ',');
	```

	```
	 id_autor |            nombre            | nacionalidad 
	----------+------------------------------+--------------
			1 | Miguel de Cervantes Saavedra | Española
			2 | Jane Austen                  | Británica
			3 | Jorge Luis Borges            | Argentina
			4 | Haruki Murakami              | Japonesa
			5 | Virginia Woolf               | Británica
			6 | Gabriel García Márquez       | Colombiana
			7 | Isabel Allende               | Chilena
			8 | Julio Cortázar               | Argentina
			9 | Mario Vargas Llosa           | Peruana
		   10 | Laura Esquivel               | Mexicana
		   11 | Carlos Fuentes               | Mexicana
		   12 | Octavio Paz                  | Mexicana
		   13 | Alejandro Casona             | Española
		   14 | Federico García Lorca        | Española
		   15 | Benito Pérez Galdós          | Española
	```

	# LISTA PENDIENTES
	- 7.2 ON DELETE CASCADE (REJECUCIÓN EN MÁQUINA DÓNOVAN)
	- 8.2 Probar con otro usuario
