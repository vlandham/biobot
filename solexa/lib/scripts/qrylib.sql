
# all these queries can be used on the command line to query the ngslims database like 
# ngsqry project_collab Zeitlinger-2011-02-24

[sf]
select * from ngslims.lims_samplefactors

[project_collab]
select
distinct a.email as email
from ngslims.lims_project p
join ngslims.lims_projectcollaborator c on c.project_id = p.id
join ngslims.lims_limsuser u on u.id = c.collaborator_id
join ngslims.auth_user a on a.id = u.user_id
where
p.title like ?
order by a.email

[fc_collab]
select
distinct a.email as email
FROM ngslims.lims_flowcell fc
join ngslims.lims_lane lane on lane.flowcell_id=fc.id
join ngslims.lims_lane_library lane_library on lane_library.lane_id = lane.id
join ngslims.lims_library library on library.id = lane_library.library_id
join ngslims.lims_project p on p.id = library.project_id
join ngslims.lims_projectcollaborator c on c.project_id = p.id
join ngslims.lims_limsuser u on u.id = c.collaborator_id
join ngslims.auth_user a on a.id = u.user_id
where
fc.name like ?
order by a.email

[project_analyst_pi]
select
distinct a.email as email
from ngslims.lims_project p
join ngslims.lims_projectcollaborator c on c.project_id = p.id
join ngslims.lims_limsuser u on u.id = c.collaborator_id
join ngslims.auth_user a on a.id = u.user_id
where
p.title like ?
and (u.analyst = 1 or u.pi = 1)
order by a.email

[fc_analyst_pi]
select
distinct a.email as email
FROM ngslims.lims_flowcell fc
join ngslims.lims_lane lane on lane.flowcell_id=fc.id
join ngslims.lims_lane_library lane_library on lane_library.lane_id = lane.id
join ngslims.lims_library library on library.id = lane_library.library_id
join ngslims.lims_project p on p.id = library.project_id
join ngslims.lims_projectcollaborator c on c.project_id = p.id
join ngslims.lims_limsuser u on u.id = c.collaborator_id
join ngslims.auth_user a on a.id = u.user_id
where
fc.name like ?
and (u.analyst = 1 or u.pi = 1)
order by a.email

[project_sample_flowcell_info]
SELECT
p.title as project_title,
s.sample as sample_name,
ln.lane_number,
f.name as flowcell_name,
a.completion_datetime,
a.file_directory
from ngslims.lims_project  p
join ngslims.lims_sample  s on s.project_id = p.id
join ngslims.lims_sample_library sl on sl.sample_id = s.id
join ngslims.lims_library l on l.id = sl.library_id
join ngslims.lims_lane_library ll on ll.library_id = l.id
join ngslims.lims_lane ln on ln.id = ll.lane_id
join ngslims.lims_flowcell f on f.id = ln.flowcell_id
left join ngslims.lims_analysis a on a.lane_id = ln.id
where
p.title like ?

[fc_file_dirs]
SELECT
#distinct
concat_ws('\\','\\\\dm3\\solexa-analysis',project.pi,project.submitter,project.title,fc.name) as windowsDir
,concat_ws('/','/n/analysis',project.pi,project.submitter,project.title,fc.name) as unixDir
,group_concat(lane_number order by lane_number) as lanes
FROM ngslims.lims_flowcell fc
join ngslims.lims_lane lane on lane.flowcell_id=fc.id
join ngslims.lims_lane_library lane_library on lane_library.lane_id = lane.id
join ngslims.lims_library library on library.id = lane_library.library_id
join ngslims.lims_project project on project.id = library.project_id
WHERE
fc.name like ?
and library.name != 'Phi X' -- c.f. http://trac/projects/ngslims/ticket/52
and library.name not like 'outsource %' -- C.f. http://trac/projects/ngslims/ticket/52
-- and pi != 'Molecular_Biology'
group by windowsDir, unixDir
order by lanes

[fc_lanefile_dist_cmd]
SELECT
concat('mkdir -p ', concat_ws('/','/n/analysis',project.pi,project.submitter,project.title,fc.name), ' && cp -i s_',lane_number,'*_{sequence,export}.* ',concat_ws('/','/n/analysis',project.pi,project.submitter,project.title,fc.name)) as cp
FROM ngslims.lims_flowcell fc
join ngslims.lims_lane lane on lane.flowcell_id=fc.id
join ngslims.lims_lane_library lane_library on lane_library.lane_id = lane.id
join ngslims.lims_library library on library.id = lane_library.library_id
join ngslims.lims_project project on project.id = library.project_id
WHERE
fc.name like ?
and library.name != 'Phi X' -- c.f. http://trac/projects/ngslims/ticket/52
and library.name not like 'outsource %' -- C.f. http://trac/projects/ngslims/ticket/52
-- and pi != 'Molecular_Biology'

[fc_postRunArgs]
select group_concat(dir  order by dir separator ':') as outDirs, group_concat(lanes order by dir separator ':') as laneSet from
(
SELECT
fc.name as fc_name,
concat_ws('/','/n/analysis',project.pi,project.submitter,project.title,fc.name) as dir ,group_concat(lane_number order by lane_number) as lanes
FROM ngslims.lims_flowcell fc
join ngslims.lims_lane lane on lane.flowcell_id=fc.id
join ngslims.lims_lane_library lane_library on lane_library.lane_id = lane.id
join ngslims.lims_library library on library.id = lane_library.library_id
join ngslims.lims_project project on project.id = library.project_id
WHERE
fc.name like ?
and library.name != 'Phi X' -- c.f. http://trac/projects/ngslims/ticket/52
and library.name not like 'outsource %' -- C.f. http://trac/projects/ngslims/ticket/52
-- and pi != 'Molecular_Biology'
group by dir
) as dl
 group by fc_name

[fc_distDir]
SELECT
concat_ws('/','/n/analysis',project.pi,project.submitter,project.title,fc.name) as dir
FROM ngslims.lims_flowcell fc
join ngslims.lims_lane lane on lane.flowcell_id=fc.id
join ngslims.lims_lane_library lane_library on lane_library.lane_id = lane.id
join ngslims.lims_library library on library.id = lane_library.library_id
join ngslims.lims_project project on project.id = library.project_id
WHERE
fc_name like ?
and library.name not like 'outsource %' -- C.f. http://trac/projects/ngslims/ticket/52
-- and pi != 'Molecular_Biology'
group by dir

[fc_lane_library_samples]
SELECT
fc.name as FCID,
lane.lane_number as lane,
group_concat(distinct s.genome_version) as genome_version,
library.name as library,
group_concat(s.sample) as sample,
project.pi as lab,
count(s.sample) as sampleCount,
seq.number_cycles as seq_cycles,
s.project_type as project_type,
seq.protocol as protocol
FROM ngslims.lims_flowcell fc
join ngslims.lims_lane lane on lane.flowcell_id=fc.id
join ngslims.lims_lane_library lane_library on lane_library.lane_id = lane.id
join ngslims.lims_library library on library.id = lane_library.library_id
join ngslims.lims_project project on project.id = library.project_id
join ngslims.lims_sample_library sl on sl.library_id = library.id
join ngslims.lims_sample s on sl.sample_id = s.id
join ngslims.lims_seq seq on fc.id = seq.flowcell_id
WHERE
fc.name like ?
GROUP BY lane, library
ORDER BY lane
