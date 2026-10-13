-- INSTRUCCIÓN DE CREACIÓN DE BASE DE DATOS:
-- Ejecutar en psql o cliente SQL conectado a postgres antes de correr el script:
-- CREATE DATABASE viveros WITH OWNER = admin_viveros ENCODING = 'UTF8';

-- Ejecución con rol admin_viveros 
SET ROLE admin_viveros;

-- Limpieza del esquema (rejecución limpia)
DROP VIEW IF EXISTS v_cliente_resumen CASCADE;
DROP VIEW IF EXISTS v_pedido_detalle CASCADE;

DROP TABLE IF EXISTS producto_pedido CASCADE;
DROP TABLE IF EXISTS pedido CASCADE;
DROP TABLE IF EXISTS correo_cliente CASCADE;
DROP TABLE IF EXISTS telefono_cliente CASCADE;
DROP TABLE IF EXISTS cliente CASCADE;
DROP TABLE IF EXISTS asignacion CASCADE;
DROP TABLE IF EXISTS tarea CASCADE;
DROP TABLE IF EXISTS empleado_puesto CASCADE;
DROP TABLE IF EXISTS puesto CASCADE;
DROP TABLE IF EXISTS correo_empleado CASCADE;
DROP TABLE IF EXISTS telefono_empleado CASCADE;
DROP TABLE IF EXISTS empleado CASCADE;
DROP TABLE IF EXISTS zona_producto CASCADE;
DROP TABLE IF EXISTS producto CASCADE;
DROP TABLE IF EXISTS zona CASCADE;
DROP TABLE IF EXISTS vivero CASCADE;

-- Creación de tablas y relaciones (FK)

CREATE TABLE vivero (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    latitud NUMERIC(8,6) NOT NULL,
    longitud NUMERIC(9,6) NOT NULL
);

-- ZONA (Entidad Débil de Vivero)
CREATE TABLE zona (
    id_vivero INT NOT NULL,
    letra_zona CHAR(1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    tipo_ambiente VARCHAR(50) NOT NULL,
    superficie NUMERIC(10,2) NOT NULL,
    latitud NUMERIC(8,6) NOT NULL,
    longitud NUMERIC(9,6) NOT NULL,
    PRIMARY KEY (id_vivero, letra_zona),
    FOREIGN KEY (id_vivero) REFERENCES vivero(id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_zona_superficie CHECK (superficie > 0)
);

-- PRODUCTO
CREATE TABLE producto (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10,2) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    CONSTRAINT chk_producto_precio CHECK (precio >= 0)
);

-- ZONA_PRODUCTO (Relación N:M - Stock)
CREATE TABLE zona_producto (
    id_vivero INT NOT NULL,
    letra_zona CHAR(1) NOT NULL,
    id_producto INT NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id_vivero, letra_zona, id_producto),
    FOREIGN KEY (id_vivero, letra_zona) REFERENCES zona(id_vivero, letra_zona) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES producto(id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_stock_positivo CHECK (stock >= 0)
);

-- EMPLEADO
CREATE TABLE empleado (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido_1 VARCHAR(50) NOT NULL,
    apellido_2 VARCHAR(50),
    dni VARCHAR(9) NOT NULL UNIQUE,
    fecha_contratacion DATE NOT NULL DEFAULT CURRENT_DATE
);

-- TELEFONO_EMPLEADO (Multivaluado)
CREATE TABLE telefono_empleado (
    id_empleado INT NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    PRIMARY KEY (id_empleado, telefono),
    FOREIGN KEY (id_empleado) REFERENCES empleado(id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- CORREO_EMPLEADO (Multivaluado)
CREATE TABLE correo_empleado (
    id_empleado INT NOT NULL,
    correo VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_empleado, correo),
    FOREIGN KEY (id_empleado) REFERENCES empleado(id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- PUESTO
CREATE TABLE puesto (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

-- EMPLEADO_PUESTO (Histórico N:M)
CREATE TABLE empleado_puesto (
    id_empleado INT NOT NULL,
    id_puesto INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    PRIMARY KEY (id_empleado, id_puesto, fecha_inicio),
    FOREIGN KEY (id_empleado) REFERENCES empleado(id) 
        ON DELETE CASCADE ON UPDATE CASCADE, -- Eliminar empleado => no tiene sentido mantener sus puestos
    FOREIGN KEY (id_puesto) REFERENCES puesto(id) 
        ON DELETE RESTRICT ON UPDATE CASCADE, -- Eliminar puesto => tiene que bloquear el borrado si hay empleados asignados
    CONSTRAINT chk_puesto_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);

-- TAREA (Entidad Fuerte)
CREATE TABLE tarea (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo VARCHAR(50) NOT NULL
);

-- ASIGNACION (Relación Ternaria)
CREATE TABLE asignacion (
    id_empleado INT NOT NULL,
    id_tarea INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    indice_productividad NUMERIC(4,2),
    id_vivero INT NOT NULL,
    letra_zona CHAR(1) NOT NULL,
    PRIMARY KEY (id_empleado, id_tarea, fecha_inicio),
    FOREIGN KEY (id_empleado) REFERENCES empleado(id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_tarea) REFERENCES tarea(id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_vivero, letra_zona) REFERENCES zona(id_vivero, letra_zona) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_asignacion_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    CONSTRAINT chk_productividad CHECK (indice_productividad IS NULL OR (indice_productividad BETWEEN 0 AND 10))
);

-- CLIENTE
CREATE TABLE cliente (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido_1 VARCHAR(50) NOT NULL,
    apellido_2 VARCHAR(50),
    fidelizacion BOOLEAN NOT NULL DEFAULT FALSE
);

-- TELEFONO_CLIENTE (Multivaluado)
CREATE TABLE telefono_cliente (
    id_cliente INT NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    PRIMARY KEY (id_cliente, telefono),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- CORREO_CLIENTE (Multivaluado)
CREATE TABLE correo_cliente (
    id_cliente INT NOT NULL,
    correo VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_cliente, correo),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- PEDIDO
CREATE TABLE pedido (
    id SERIAL PRIMARY KEY,
    fecha_realizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo_pago VARCHAR(30) NOT NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'Pendiente',
    id_cliente INT NOT NULL,
    id_empleado INT,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_empleado) REFERENCES empleado(id) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_pedido_estado CHECK (estado IN ('Pendiente', 'Procesando', 'Enviado', 'Entregado', 'Cancelado')),
    CONSTRAINT chk_pedido_pago CHECK (metodo_pago IN ('Efectivo', 'Tarjeta', 'Transferencia', 'PayPal'))
);

-- PRODUCTO_PEDIDO (Relación N:M)
CREATE TABLE producto_pedido (
    id_producto INT NOT NULL,
    id_pedido INT NOT NULL,
    unidades INT NOT NULL,
    PRIMARY KEY (id_producto, id_pedido),
    FOREIGN KEY (id_producto) REFERENCES producto(id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_pedido) REFERENCES pedido(id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_unidades_positivas CHECK (unidades > 0)
);

-- Vistas para atributos calculados

-- Vista para el Importe Total de cada Pedido
CREATE VIEW v_pedido_detalle AS
SELECT 
    p.id AS id_pedido,
    p.fecha_realizacion,
    p.estado,
    p.metodo_pago,
    p.id_cliente,
    p.id_empleado,
    COALESCE(SUM(pp.unidades * prod.precio), 0) AS importe_total
FROM pedido p
LEFT JOIN producto_pedido pp ON p.id = pp.id_pedido
LEFT JOIN producto prod ON pp.id_producto = prod.id
GROUP BY p.id, p.fecha_realizacion, p.estado, p.metodo_pago, p.id_cliente, p.id_empleado;

-- Vista para el número de Pedidos Realizados por Cliente
CREATE VIEW v_cliente_resumen AS
SELECT 
    c.id AS id_cliente,
    c.nombre,
    c.apellido_1,
    c.apellido_2,
    c.fidelizacion,
    COUNT(p.id) AS pedidos_realizados
FROM cliente c
LEFT JOIN pedido p ON c.id = p.id_cliente
GROUP BY c.id, c.nombre, c.apellido_1, c.apellido_2, c.fidelizacion;

-- Inserción de datos de ejemplo

INSERT INTO vivero (nombre, latitud, longitud) VALUES
('Vivero Central La Laguna', 28.487100, -16.315900),
('Vivero del Sur Arona', 28.100200, -16.680500),
('Vivero Verde Orotava', 28.390100, -16.523300),
('Vivero Costa Adeje', 28.082500, -16.732100),
('Vivero Anaga Plantas', 28.531000, -16.195000);

INSERT INTO zona (id_vivero, letra_zona, latitud, longitud, nombre, tipo_ambiente, superficie) VALUES
(1, 'A', 28.487110, -16.315910, 'Invernadero Principal', 'Cubierto', 450.00),
(1, 'B', 28.487120, -16.315920, 'Exterior Frutales', 'Exterior', 1200.00),
(2, 'A', 28.100210, -16.680510, 'Sombra Tropical', 'Sombra', 350.00),
(3, 'A', 28.390110, -16.523310, 'Semillero y Flores', 'Cubierto', 500.00),
(4, 'A', 28.082510, -16.732110, 'Cactus y Suculentas', 'Exterior', 800.00);

INSERT INTO producto (nombre, precio, tipo) VALUES
('Palmera Canaria (Phoenix canariensis)', 45.50, 'Planta Exterior'),
('Orquídea Phalaenopsis', 18.00, 'Planta Interior'),
('Sustrato Universal 50L', 9.95, 'Insumo'),
('Maceta Cerámica 30cm', 14.20, 'Accesorio'),
('Drago Canario (Dracaena draco)', 65.00, 'Planta Exterior');

INSERT INTO zona_producto (id_vivero, letra_zona, id_producto, stock) VALUES
(1, 'A', 2, 40),
(1, 'B', 1, 15),
(1, 'B', 5, 10),
(2, 'A', 3, 100),
(3, 'A', 4, 25);

INSERT INTO empleado (nombre, apellido_1, apellido_2, dni, fecha_contratacion) VALUES
('Carlos', 'González', 'Pérez', '12345678A', '2021-01-15'),
('María', 'Rodríguez', 'Hernández', '87654321B', '2022-03-01'),
('Juan', 'López', 'Martín', '11223344C', '2020-06-10'),
('Elena', 'Gómez', 'Díaz', '44332211D', '2023-09-15'),
('Pedro', 'Santana', 'Suárez', '55667788E', '2019-11-20');

INSERT INTO telefono_empleado (id_empleado, telefono) VALUES
(1, '600111222'),
(1, '922111222'),
(2, '600333444'),
(3, '600555666'),
(4, '600777888');

INSERT INTO correo_empleado (id_empleado, correo) VALUES
(1, 'carlos.gonzalez@viveros.es'),
(2, 'maria.rodriguez@viveros.es'),
(3, 'juan.lopez@viveros.es'),
(4, 'elena.gomez@viveros.es'),
(5, 'pedro.santana@viveros.es');

INSERT INTO puesto (nombre) VALUES
('Encargado de Vivero'),
('Jardinero Especialista'),
('Técnico Agrónomo'),
('Comercial de Ventas'),
('Auxiliar de Mantenimiento');

INSERT INTO empleado_puesto (id_empleado, id_puesto, fecha_inicio, fecha_fin) VALUES
(1, 1, '2021-01-15', NULL),
(2, 2, '2022-03-01', '2023-02-28'),
(2, 3, '2023-03-01', NULL),
(3, 2, '2020-06-10', NULL),
(4, 4, '2023-09-15', NULL);

INSERT INTO tarea (nombre, descripcion, tipo) VALUES
('Riego de Invernadero', 'Control de humedad e irrigación programada', 'Mantenimiento'),
('Poda de Frutales', 'Recorte de ramas de la zona exterior', 'Poda'),
('Control de Plagas', 'Aplicación de fitosanitarios ecológicos', 'Sanidad vegetal'),
('Preparación de Sustratos', 'Mezcla de turba y compost', 'Preparación'),
('Atención al Cliente', 'Asesoramiento y facturación en tienda', 'Comercial');

INSERT INTO asignacion (id_empleado, id_tarea, fecha_inicio, fecha_fin, indice_productividad, id_vivero, letra_zona) VALUES
(1, 3, '2024-01-10', '2024-01-12', 9.50, 1, 'A'),
(2, 1, '2024-02-01', NULL, 8.75, 1, 'A'),
(3, 2, '2024-02-05', '2024-02-06', 7.80, 1, 'B'),
(4, 5, '2024-03-01', NULL, 9.10, 2, 'A'),
(5, 4, '2024-03-10', '2024-03-11', 8.20, 3, 'A');

INSERT INTO cliente (nombre, apellido_1, apellido_2, fidelizacion) VALUES
('Ana', 'Morales', 'García', TRUE),
('Luis', 'Fernández', 'Torres', FALSE),
('Carmen', 'Benítez', 'Ramos', TRUE),
('David', 'Castro', 'Navarro', FALSE),
('Sonia', 'Mendoza', 'Sánchez', TRUE);

INSERT INTO telefono_cliente (id_cliente, telefono) VALUES
(1, '677123456'),
(2, '688234567'),
(3, '699345678'),
(3, '922345678'),
(4, '655456789');

INSERT INTO correo_cliente (id_cliente, correo) VALUES
(1, 'ana.morales@gmail.com'),
(2, 'luis.ft@hotmail.com'),
(3, 'carmen.benitez@yahoo.es'),
(4, 'david.castro@outlook.com'),
(5, 'sonia.mendoza@gmail.com');

INSERT INTO pedido (fecha_realizacion, metodo_pago, estado, id_cliente, id_empleado) VALUES
('2024-03-01 10:30:00', 'Tarjeta', 'Entregado', 1, 4),
('2024-03-05 12:15:00', 'Efectivo', 'Entregado', 2, 4),
('2024-03-10 16:45:00', 'Transferencia', 'Enviado', 3, 4),
('2024-03-12 11:00:00', 'PayPal', 'Procesando', 1, 4),
('2024-03-15 09:20:00', 'Tarjeta', 'Pendiente', 5, NULL);

INSERT INTO producto_pedido (id_producto, id_pedido, unidades) VALUES
(1, 1, 2),
(2, 1, 1),
(3, 2, 5),
(5, 3, 1),
(4, 4, 3);

-- Ejemplos representativos de las operaciones DELETE

-- DELETE CON CASCADE (Entidad Débil / Multivaluados)
-- Al borrar el Vivero 5, se eliminan sus zonas y su stock asociado.
DELETE FROM vivero WHERE id = 5;

-- DELETE CON SET NULL
-- Al borrar al empleado 5, sus datos de contacto se borran en cascada,
-- pero sus ventas en la tabla 'pedido' pasan a tener id_empleado = NULL.
DELETE FROM empleado WHERE id = 5;

-- Ejemplo DELETE CON RESTRICT Y BORRADO MANUAL CONTROLADO
-- Eliminar las líneas de pedido y pedido del cliente 1 antes de eliminar al cliente.
DELETE FROM producto_pedido WHERE id_pedido IN (SELECT id FROM pedido WHERE id_cliente = 1);
DELETE FROM pedido WHERE id_cliente = 1;
DELETE FROM cliente WHERE id = 1;