1. Creación de la base de datos
2. Crear una base de datos llamada biblioteca.

```bash
	CREATE DATABASE biblioteca;
	/c biblioteca
```

3. Creación de usuarios
4. Crear dos usuarios:
5. admin_biblio con permisos de administrador sobre la base de datos.
6. usuario_biblio con permisos solo de lectura.

```bash
CREATE ROLE admin_biblio WITH LOGIN PASSWORD 'adminpass'
CREATE ROLE usuario_biblio WITH LOGIN PASSWORD 'usuariopass'
GRANT ALL PRIVILEGES ON DATABASE biblioteca TO admin_biblio;
```

7. Crear un rol llamado lectores con permisos únicamente de consulta sobre todas las tablas de la base de datos.

```bash
CREATE ROLE lectores NOLOGIN
```

8. Asignar el usuario usuario_biblio a este rol.

```bash
GRANT lectores TO usuario_biblio;
```

9. Consultar las tablas del sistema para listar todos los usuarios creados (pg_roles).

```bash
SELECT rolname, rolsuper, rolcreaterole, rolcreatedb, rolcanlogin FROM pg_roles ORDER BY rolname;
```

10. Cambiar la contraseña del usuario usuario_biblio.

```bash
 ALTER ROLE usuario_biblio WITH PASSWORD 1234;
```

11. Configurar permisos de tal forma que el usuario usuario_biblio no pueda eliminar registros en ninguna tabla.

// Elimina permisos de creación/eliminación a todos los usuarios por defecto

```bash
REVOKE ALL ON SCHEMA public FROM PUBLIC;
```

12. Creación de tablas Crear las siguientes tablas con sus respectivas claves primarias:
    

13. autores(id_autor, nombre, nacionalidad)

```bash
CREATE TABLE autores(
id_autor SERIAL PRIMARY KEY,
nombre TEXT NOT NULL,
nacionalidad TEXT
);
```

    
14. libros(id_libro, titulo, año_publicacion, id_autor)