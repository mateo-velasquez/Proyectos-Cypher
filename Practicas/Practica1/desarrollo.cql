// 1. Utilizando Neo4J Bloom. Una imagen del esquema general del grafo [4 puntos]
Hecho
// 2. Utilizando Gephi. Una imagen del grafo completo. [4 puntos]
hecho

// 3. ¿Cuáles son los tipos de nodos y sus atributos? [4 puntos]
call db.schema.nodeTypeProperties

// 4. ¿Cuáles son los tipos de relaciones y sus atributos? [4 puntos]
call db.schema.relTypeProperties

// 5. Una o varias consultas en cypher que me indique cuantos nodos hay de cada tipo [4 puntos]
MATCH (n)
RETURN labels(n) AS tipo_nodo, count(n) AS total
ORDER BY total DESC

// 6. ¿Cómo demuestras que es correcto el resultado de la consulta anterior? [4 puntos]
MATCH (n)
WITH COUNT (n) AS total
RETURN total

// 7. Una o varias consultas en cypher que me indique cuantas relaciones hay de cada tipo [4 puntos]
MATCH ()-[r]-()
RETURN TYPE(r) AS tipo_relacion, COUNT(r) AS total
ORDER BY total DESC

// 8. ¿Cómo demuestras que es correcto el resultado de la consulta anterior? [4 puntos]
MATCH (n)-[r]-(m)
WITH COUNT (r) AS total
RETURN total

// 9. ¿Cuál es el diámetro del grafo? [4 puntos]
// Primero elaboro un subgrafo
CALL gds.graph.project('myGrapH', 
                            ['Movie', 
                            'Droid', 
                            'Person'],
                         '*');

// Ahora busco todos los caminos cortos y me quedo
CALL gds.allShortestPaths.stream('myGraph')
YIELD sourceNodeId, targetNodeId, distance
RETURN max(distance) AS diametro;

// 10. Explica con tus palabras para que te sirve conocer el diámetro del grafo [4 puntos]
Conocer el diámetro de un grafo me permite conocer el número máximo de la cantidad de 
relaciones que necesitamos para poder llegar de un nodo a cualquier otro nodo del grafo. 
Esto puede ser muy útil para buscar que tan disperso está el grafo 
(en el sentido de que si los nodos tienen muchas conexiones entre ellos y se puede acceder 
a los caminos cortos de una forma muy rápida).

// 11. Un listado de las personas, el número de veces que habló con otra persona y como lista el nombre de las personas con las que habló. El resultado debe estar ordenado en forma descendente con base en veces que habló con otra persona. [4 puntos]
MATCH (n:Person)-[r:SPEAKS_WITH]-(m:Person)
WITH n.name AS nombre, COUNT(r) AS total_personas_habladas, COLLECT(m.name) AS lista
RETURN nombre, total_personas_habladas, lista
ORDER BY total_personas_habladas DESC

// 12. Una consulta que reciba el nombre de la persona y muestre una tabla con, el nombre de la persona, el número de veces que habló con un droide y una lista de los nombres de los droides. Utiliza el nombre de la persona que habló con más personas como valor del parámetro para probar tu consulta. [4 puntos]
MATCH (n:Person)-[r:SPEAKS_WITH]-(m:Person)
WITH n.name AS nombre, COUNT(m) AS total_personas_habladas, COLLECT(total_personas_habladas) AS lista 
ORDER BY total_personas_habladas DESC
LIMIT 1

// 13. Realiza una frase de búsqueda en Bloom que reciba el nombre el nombre de la persona como parámetro y te regrese, el grafo que incluya la relación y las películas en las que apareció. Prueba con la persona de tu elección como parámetro muestra el grafo resultante como par ordenado. [4 puntos]
// Para este caso voy a armar la consulta de Cypher con un parametro y se lo agrego en el título
MATCH (p:Person {name: $nombre})-[r:APPEARS_IN]->(m:Movie)
RETURN p, r, m

// 14. Una consulta que muestre el OUT_DEGREE de los nodos tipo persona. El resultado debe estar ordenado de forma descendente por OUT_DEGREE. [4 puntos]
MATCH (n:Person)-[r]->(m)
WITH n.name AS Nombre, COUNT(r) AS OUT_DEGREE
RETURN Nombre, OUT_DEGREE
ORDER BY OUT_DEGREE DESC

// 15. Realiza una frase de búsqueda en Bloom que reciba el nombre de una película como parámetro y regrese el grafo con los nodos alcanzables a dos saltos. Prueba con las películas de tu elección como parámetro muestra el grafo resultante. Además, representa el grafo como una matriz. [4 puntos]
MATCH (m:Movie{name: $nombre})-[r1]-(n)-[r2]-(l)
WHERE m <> l
RETURN m, r1, n, r2, l

//test: "Episode VI: Return of the Jedi"

// 16. Realiza una frase de búsqueda en Bloom que reciba el nombre de un droide y muestre el grafo, sin importar la dirección, que conecta el nodo inicio, las relaciones y los nodos destino a 2 saltos. Prueba con R2-D2 como entrada y muestra el grafo resultante [4 puntos]
MATCH (d:Droid{name: $nombre})-[r1]-(n)-[r2]-(l)
WHERE d <> l
RETURN d, r1, n, r2, l


// 17. Realiza una consulta que muestre cuantos patrones (:Droid)–[:SPEAKS_WITH]->(:Person) se presentan en la base de datos. ¿Cómo compruebas que tu resultado es correcto? [4 puntos]
MATCH (d:Droid)-[r:SPEAKS_WITH]->(p:Person)
RETURN COUNT(r) AS total
// Para verificar:
MATCH (d:Droid)-[:SPEAKS_WITH]->(p:Person)
RETURN d.name AS droid, p.name AS persona;

// 18. Realiza una consulta que muestre el top 10 de nodos con mayor IN_DEGREE [4 puntos]
MATCH (n)<-[r]-(l)
WITH n.name AS nombre, COUNT(r) AS IN_DEGREE
RETURN nombre, IN_DEGREE
ORDER BY IN_DEGREE DESC
LIMIT 10

// 19. Crea los nodos y relaciones necesarias para que tú hables con un droide y aparezcas en la película con menor IN_DEGREE [4 puntos]
// Primero creo la consulta para obtener el top con peliculas con menor IN_DEGREE
MATCH (n:Movie)<-[r]-(l)
WITH n.name AS nombre, COUNT(r) AS IN_DEGREE
RETURN nombre, IN_DEGREE
ORDER BY IN_DEGREE ASC
LIMIT 1
// Ahora simplemente creamos nuestro nodo y creamos la relacion con la película
MERGE (p:Person {name: 'Mateo Velasquez'})
WITH p, nombre
MATCH (m:Movie)
WHERE m.name = nombre
MERGE (p)-[:APPEARS_IN]->(m);

//Ahora la parte del droide:
MATCH (p:Person {name: 'Mateo Velasquez'}), (d:Droid{name: 'R2-D2'})
WITH p, d
MERGE (p)-[r:SPEAKS_WITH]->(d)

// 20. Muestra la ruta más corta entre CHEWBACCA y tú. [4 puntos]
MATCH c = shortestPath((p:Person {name: 'Tom Hanks'})-[*]-(op:Person {name: 'Keanu Reeves'}))
RETURN c
// Está hecho como lo hicimos en clases.
