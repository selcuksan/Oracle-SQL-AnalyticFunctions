create table bricks (
  brick_id integer,
  colour   varchar2(10),
  shape    varchar2(10),
  weight   integer
);

insert into bricks values ( 1, 'blue', 'cube', 1 );
insert into bricks values ( 2, 'blue', 'pyramid', 2 );
insert into bricks values ( 3, 'red', 'cube', 1 );
insert into bricks values ( 4, 'red', 'cube', 2 );
insert into bricks values ( 5, 'red', 'pyramid', 3 );
insert into bricks values ( 6, 'green', 'pyramid', 1 );

commit;

-- Introduction
select count(*) from bricks;

select count(*) over () from bricks;

select b.*, 
       count(*) over () total_count 
from   bricks b;

-- Partition By
select colour, count(*), sum ( weight )
from   bricks
group  by colour;

select b.*, 
       count(*) over (
         partition by colour
       ) bricks_per_colour, 
       sum ( weight ) over (
         partition by colour
       ) weight_per_colour
from   bricks b;

select b.*, 
       count(*) over (
         partition /* TODO */ by shape
       ) bricks_per_shape, 
       median ( weight ) over (
         partition /* TODO */ by shape
       ) median_weight_per_shape
from   bricks b
order  by shape, weight, brick_id;

-- Order By
select b.*, 
       count(*) over (
         order by brick_id
       ) running_total, 
       sum ( weight ) over (
         order by brick_id
       ) running_weight
from   bricks b;

-- Partition By + Order By
select b.*, 
       count(*) over (
         partition by colour
         order by brick_id
       ) running_total, 
       sum ( weight ) over (
         partition by colour
         order by brick_id
       ) running_weight
from   bricks b;

-- Windowing Clause
select b.*, 
       count(*) over (
         order by weight
       ) running_total, 
       sum ( weight ) over (
         order by weight 
         rows between unbounded preceding and current row
       ) running_weight
from   bricks b
order  by weight;

select b.*, 
       count(*) over (
         order by weight, brick_id
         rows between unbounded preceding and current row
       ) running_total, 
       sum ( weight ) over (
         order by weight, brick_id
         rows between unbounded preceding and current row
       ) running_weight
from   bricks b
order  by weight, brick_id;

-- Sliding Windows
select b.*, 
       sum ( weight ) over (
         order by weight
         rows between 1 preceding and current row
       ) running_row_weight, 
       sum ( weight ) over (
         order by weight
         range between 1 preceding and current row
       ) running_value_weight
from   bricks b
order  by weight, brick_id;

select b.*, 
       sum ( weight ) over (
         order by weight
         rows between 1 preceding and 1 following
       ) sliding_row_window, 
       sum ( weight ) over (
         order by weight
         range between 1 preceding and 1 following
       ) sliding_value_window
from   bricks b
order  by weight;

select b.*, 
       count (*) over (
         order by weight
         range between 2 preceding and 1 preceding 
       ) count_weight_2_lower_than_current, 
       count (*) over (
         order by weight
         range between 1 following and 2 following
       ) count_weight_2_greater_than_current
from   bricks b
order  by weight;

-- Filtering Analytic Functions
select colour from bricks
group  by colour
having count(*) >= 2;

select colour from bricks
where  count(*) over ( partition by colour ) >= 2; -- ERROR OCCURES

select * from (
  select b.*,
         count(*) over ( partition by colour ) colour_count
  from   bricks b
)
where  colour_count >= 2;

-- More Analytic Functions
select brick_id, weight, 
       row_number() over ( order by weight ) rn, 
       rank() over ( order by weight ) rk, 
       dense_rank() over ( order by weight ) dr
from   bricks;

select b.*,
       lag ( WEIGHT ) over ( order by brick_id ) lag_,
       lead ( WEIGHT ) over ( order by brick_id ) lead_
from   bricks b;

select b.*,
       first_value ( weight ) over ( 
         order by brick_id 
       ) first_weight_by_id,
       last_value ( weight ) over (
         order by brick_id 
       ) last_weight_by_id
from   bricks b;

select b.*,
       first_value ( weight ) over ( 
         partition by colour order by BRICK_ID
       ) first_weight_by_id,
       last_value ( weight ) over ( 
         partition by colour order by BRICK_ID 
       ) last_weight_by_id
from   bricks b;

       first_value ( weight ) over ( 
         partition by colour 
       ) first_weight_by_id,
       last_value ( weight ) over ( 
         partition by colour 
       ) last_weight_by_id
from   bricks b;
