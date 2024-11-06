create temporary table Project_report AS
SELECT
    location.address AS Address,
    location.town_name AS Town,
    location.province_name AS Province,
    water_source.source_id,
    water_source.type_of_water_source AS Source_type,
    results,
case
	when  results = "Contaminated: Biological"  then "Install UV filter"
    when  results = "Contaminated: Chemical"  then "Install RO filter"
    when  type_of_water_source = "river"  then "Drill well"
    when  (type_of_water_source = "shared_tap" AND (time_in_queue >= 30))  then CONCAT('Install ', FLOOR(time_in_queue/30), ' tap(s) nearby')
    when  type_of_water_source = "tap_in_home_broken"  then "Diagnose local infrastructure"
    else null
end as Improvement
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1 -- This must always be true
AND ( -- AND one of the following (OR) options must be true as well.
results!= 'Clean'
OR type_of_water_source IN ('tap_in_home_broken','river')
OR (type_of_water_source = 'shared_tap' AND time_in_queue >=30)
)
