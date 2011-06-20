require 'mysql'

class Lims
  def self.flowcell_lanes flowcell_id
    results = query(flowcell_lanes_query(flowcell_id))
    results
  end

  def self.query query_string
    res = nil
    begin
      dbh = Mysql.real_connect("ngslims", "webuser", "welcome232", "ngslims")
      res = dbh.query query_string
    ensure
      dbh.close if dbh
    end
    res
  end

  def self.flowcell_lanes_query(flowcell_id)
query <<EOS
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
fc.name like #{flowcell_id} 
GROUP BY lane, library
ORDER BY lane
EOS
    query
  end

end
