create role ma 
IN ROLE analyst
LOGIN
inherit
PASSWORD 'm0t1.n'
;



grant usage on schema lookup to analyst;
grant ALL on schema tmp to analyst;
grant ALL on schema vfa to analyst;


grant all on ALL TABLES IN schema tmp to analyst;
grant all on ALL TABLES IN schema vfa to analyst;
grant select on ALL TABLES IN schema lookup to analyst;


ALTER ROLE ma SET search_path TO "$user", public, topology;