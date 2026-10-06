### Entidades (con sus atributos)
<!-- Descripción de cada una de las entidades definidas.-->

* **Vivero** con Georreferenciación (Latitud y Longitud), Nombre, ID.
* **Zona** con Georreferenciación (Latitud y Longitud),
Nombre, Tipo de Ambiente, Superficie, Letra. 
  * *Entidad débil y dependencia en identificación (necesita de Vivero)*
* **Producto** con
Nombre comercial, Nombre científico, Precio unitario, ID.
  
  (Jerarquía de herencia exclusiva y parcial)
  Un producto debe ser (exclusivo) de tipo Planta, Jardinería o Decoración, o de otro tipo (parcial).
  *  Planta 
  *  Jardinería
  *  Decoración.
* **Empleado** con Nombre, Apellidos, Teléfono, Email, Fecha de contratación, DNI, ID.
* **Cliente** con Fidelización (*o Tajinaste Plus*), Pedidos realizados, Nombre, Apellidos, Teléfono, Email, ID.
* **Pedido** con Fecha de realización, Estado, Forma de pago, Total del importe, ID.

### Descripción de Atributos de entidades y atributos de relaciones
<!--Descripción y ejemplos ilustrativos del dominio de cada uno de los atributos de las entidades y de las relaciones.-->

* **Vivero**
  * Atributo identificador: ID.
  * Atributo compuesto: Georreferenciación compuesto por Latitud y Longitud.
  * Atributos descriptores: Nombre.
* **Zona**
  * Atributo discriminante: Letra.
  * Atributo compuesto: Georreferenciación compuesto por Latitud y Longitud.
  * Atributos descriptores: Nombre, Tipo de Ambiente, Superficie.
* **Producto**
  * Atributo identificador: ID.
  * Atributos descriptores: Nombre comercial, Nombre científico, Precio unitario.
* **Empleado**
  * Atributo identificador: ID.
  * Atributo compuesto: Apellidos compuesto por Primer Apellido y Segundo Apellido.
  * Atributos descriptores: Nombre, DNI, Fecha de contratación.
  * Atributos multivaluados: Email, Teléfono.
* **Cliente**
  * Atributo identificador: ID.
  * Atributo compuesto: Apellidos compuesto por Primer Apellido y Segundo Apellido.
  * Atributos descriptores: Nombre, Fidelización (*o Tajinaste Plus*).
  * Atributos multivaluados: Email, Teléfono.
  * Atributos calculados: Pedidos realizados.
* **Pedido**
  * Atributo identificador: ID.
  * Atributo compuesto: Fecha de realización compuesto por Hora y Día.
  * Atributos descriptores: Estado, Forma de pago.
  * Atributos calculados: Total de importe.

**Atributos (propios) de las relaciones**

* **Relación Zona - Producto**
  * Atributos descriptores: Stock (cantidad de producto en una zona).
* **Relación Vivero - Empleado**
  * Atributos descriptores: Época del año (Época del año destinada a un empleado en un vivero concreto).
* **Relación Zona - Empleado**
  * Atributos descriptores: Tarea (Tarea desempeñada por un empleado en una zona concreta), Puesto (Puesto en el que trabaja un empleado en una zona).


### Relaciones entre entidades
<!--Descripción de cada una de las relaciones definidas. Describa con detalle la cardinalidad de cada relación.-->
* **Relación Vivero - Zona**:
  * Relación de dependencia en identificación: para identificar de forma unívoca a una Zona, es imprescindible concatenar el identificador de la entidad fuerte de la que depende (ID de Vivero) con su propio discriminante (Letra). Una Zona es intrínseca a un Vivero.
  * Cardinalidad 1:N (máximo entre participación de cada entidad). Una Zona es única a un Vivero. Un Vivero puede contener varias zonas.
* **Relación Vivero - Empleado**:
  * Cardinalidad 1:N. Un Vivero tiene asignados ningún o más empleados. Un empleado está asignado a un único Vivero en una época del año.
* **Relación Zona - Empleado**:
  * Cardinalidad 1:N. Una Zona tiene asignados ningún o más Empleados. Un empleado está asignado a una única Zona en un puesto con tarea determinada.
* **Relación Zona - Producto**:
  * Cardinalidad N:M. Una Zona tiene un stock de ningún o más Productos. Un Producto está en ninguna o más Zonas.
* **Relación Producto - Pedido**:
  * Cardinalidad N:M. Un Producto está en ningún Pedido (aún no se ha comprado/pedido) o en más Pedidos. Un Pedido tiene que tener uno o más Productos en él.
* **Relación Empleado - Pedido**:
  * Cardinalidad 1:N. Un Empleado gestiona ningún o más pedidos. Un pedido es procesado por ningún Empleado (aún no se ha procesado) o un sólo Empleado.
* **Relación Pedido - Cliente**:
  * Cardinalidad 1:N. Un Pedido es hecho por un único Cliente. Un Cliente puede realizar ningún o más Pedidos.
* **Relación de jerarquía de Producto**:
  * Un producto debe ser (exclusivo) de tipo Planta, Jardinería o Decoración, o de otro tipo (parcial).
  *  Planta 
  *  Jardinería
  *  Decoración.
  
### Restricciones semánticas
<!--
Si las considera necesarias en su modelo, añada las restricciones semánticas propuestas.
 -->