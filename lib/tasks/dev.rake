desc "Hydrate the database with some sample data to look at so that developing is easier"
task({ :sample_data => :environment}) do
  array = ["rental", "retail", "law", "rental", "law"]
  25.times do
    f = Firm.new
    f.firm_type = array.sample
    f.save 
  end
end
