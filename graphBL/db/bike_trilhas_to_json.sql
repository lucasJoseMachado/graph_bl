create extension postgis;
create extension postgis_topology;
SET search_path = topology,public;

-- select DropTopology('topologia');

select CreateTopology('topologia', 4326, 0.003/100);
alter table topologia.edge_data add column peso double precision;
alter table topologia.edge_data alter column peso set default 1;

--init topologia
select ST_CreateTopoGeo('topologia', (select st_collect(geom_way) from hh_2po_4pgr));

--include ciclovias
CREATE OR REPLACE FUNCTION inserir_todas_ciclovias_topologia() RETURNS void AS
$$
DECLARE linha RECORD;
DECLARE indice INTEGER;
DECLARE geometria GEOMETRY;
BEGIN
 FOR linha IN SELECT * FROM trilha join trilhadados using(codt) where tip_cod = 2
             LOOP
		geometria = linha.geometria;
		LOOP
			BEGIN
				FOR indice IN SELECT TopoGeo_AddLineString( 'topologia', geometria ) LOOP
					UPDATE topologia.edge_data
						SET peso = 0.8
						WHERE edge_id = indice;
				END LOOP;
				EXIT;
			EXCEPTION WHEN others THEN
				RAISE NOTICE 'Problema na geometria (%)', linha.codt;
				EXIT;
			END;
		END LOOP;
		indice = 0;
	END LOOP;
END
$$
LANGUAGE plpgsql;

select inserir_todas_ciclovias_topologia();

--count points
select count(*) from topologia.node;

--export points
SELECT array_to_json(array_agg(row_to_json(t))) FROM (
	SELECT node_id, st_asgeojson(geom) as geom FROM topologia.node
) t;

--count tracks
select count(*) from topologia.edge_data;

--export tracks
SELECT array_to_json(array_agg(row_to_json(t))) FROM (
	SELECT edge_id, start_node, end_node,
    st_length(geom) as length, st_asgeojson(geom) as geom,
    CASE WHEN peso = 0.8 THEN 'bike' ELSE 'car' END as road_type
	FROM topologia.edge_data
) t;
