require 'spec_helper'

describe "Revs-Utils" do

  before(:each) do
    
    @revs=RevsUtilsTester.new # a class defined in the spec_helper which includes the module methods we need to test 
    
  end

   it "should clean up collection names" do
     @revs.clean_collection_name(nil).should == ""
     @revs.clean_collection_name("").should == ""
     @revs.clean_collection_name(123).should == "123"
     @revs.clean_collection_name('This should be untouched').should == 'This should be untouched'
     @revs.clean_collection_name('The should be removed').should == 'should be removed'
     @revs.clean_collection_name('the should be removed').should == 'should be removed'
     @revs.clean_collection_name('THE should be removed').should == 'should be removed'
     @revs.clean_collection_name('Should the not be removed').should == 'Should the not be removed'
     @revs.clean_collection_name('The Dugdale Collection of the Revs Institute').should == 'Dugdale Collection'
     @revs.clean_collection_name('the Dugdale Collection of the revs institute').should == 'Dugdale Collection'
     @revs.clean_collection_name('Dugdale Collection of the Revs Institute').should == 'Dugdale Collection'
     @revs.clean_collection_name('Dugdale Collection OF THE REVS INSTITUTE').should == 'Dugdale Collection' 
     @revs.clean_collection_name('Dugdale Collection of the Revs institute').should == 'Dugdale Collection'     
     @revs.clean_collection_name('Revs Institute Dugdale Collection of the Revs Institute').should == 'Revs Institute Dugdale Collection'     
     @revs.clean_collection_name('of the Revs Institute The Dugdale Collection of the Revs Institute').should == 'of the Revs Institute The Dugdale Collection'     
   end
   
   it "should parse locations" do
     row={'other'=>'value','location'=>'123 Street | Palo Alto | United States'}
     @revs.parse_location(row,'location').should == row.merge('city_section'=>'123 Street ','country'=>'United States')
   end
   
   it "should lookup marques" do
     @revs.revs_lookup_marque('Ford').should == {"url"=>"http://id.loc.gov/authorities/subjects/sh85050464", "value"=>"Ford automobile"}
     @revs.revs_lookup_marque('Fords').should == {"url"=>"http://id.loc.gov/authorities/subjects/sh85050464", "value"=>"Ford automobile"}
     @revs.revs_lookup_marque('Ford Automobiles').should == {"url"=>"http://id.loc.gov/authorities/subjects/sh85050464", "value"=>"Ford automobile"}
     @revs.revs_lookup_marque('Porsche').should == {"url"=>"http://id.loc.gov/authorities/subjects/sh85105037", "value"=>"Porsche automobiles"}
     @revs.revs_lookup_marque('Bogus').should be_false
     @revs.revs_lookup_marque('').should be_false
   end
   
   it "should clean up some common format errors from an array" do 
     @revs.revs_check_formats(['black-and-white negative','color negative','leave alone']).should == ['black-and-white negatives','color negatives','leave alone']
   end

   it "should clean up some common format errors from a string" do 
     @revs.revs_check_format('black-and-white negative').should == 'black-and-white negatives'
     @revs.revs_check_format('leave alone').should == 'leave alone'
   end
      
   it "should indicate if a date is valid" do
     @revs.get_full_date('bogus').should be_false
     @revs.get_full_date('5/1/1959').should == Date.strptime("5/1/1959", '%m/%d/%Y')
     @revs.get_full_date('5-1-1959').should == Date.strptime("5/1/1959", '%m/%d/%Y')
   end

   it "should indicate if we have a valid year" do
     @revs.is_valid_year?('1959').should be_true
     @revs.is_valid_year?('bogus').should be_false
     @revs.is_valid_year?('1700').should be_false # tool old! no cars even existed yet
  end
   
   
   it "should lookup the country correctly" do
     @revs.revs_get_country('USA').should == "United States"
     @revs.revs_get_country('US').should == "United States"
     @revs.revs_get_country('United States').should == "United States"
     @revs.revs_get_country('italy').should == "Italy"
     @revs.revs_get_country('Bogus').should be_false
   end

   it "should parse a city/state correctly" do
     @revs.revs_get_city_state('San Mateo (Calif.)').should == ['San Mateo','Calif.']
     @revs.revs_get_city_state('San Mateo').should be_false
     @revs.revs_get_city_state('Indianapolis (Ind.)').should == ['Indianapolis','Ind.']
   end

   it "should lookup a state correctly" do
     @revs.revs_get_state_name('Calif').should == "California"
     @revs.revs_get_state_name('Calif.').should == "California"
     @revs.revs_get_state_name('calif').should == "California"       
     @revs.revs_get_state_name('Ind').should == "Indiana"       
     @revs.revs_get_state_name('Bogus').should == "Bogus"
   end
     
  
  it "should parse 1950s correctly" do
    
    @revs.parse_years('1950s').should == ['1950','1951','1952','1953','1954','1955','1956','1957','1958','1959']    
    
  end

  it "should parse 1955-57 correctly" do
    
    @revs.parse_years('1955-57').should == ['1955','1956','1957']    
    
  end

  it "should parse 1955 | 1955 and not produce a duplicate year" do
    
    @revs.parse_years('1955|1955').should == ['1955']    
    
  end

  it "should parse 1955-1957 | 1955-1957 and not produce duplicate years" do
    
    @revs.parse_years('1955-1957 | 1955-1957').should == ['1955','1956','1957']    
    
  end

  it "should parse 1955-1957 | 1955 | 1955 and not produce duplicate years" do
    
    @revs.parse_years('1955-1957 | 1955 | 1955').should == ['1955','1956','1957']    
    
  end

  it "should parse 1955-1957 | 1955 | 1954 and not produce duplicate years" do
    
    @revs.parse_years('1955-1957 | 1955 | 1954').should == ['1954','1955','1956','1957']    
    
  end

  it "should parse 1955-1957 correctly" do
    
    @revs.parse_years('1955-1957').should == ['1955','1956','1957']    
    
  end
  
  it "should be able to read the manifest headers file and load it as a hash" do
    file_status = File.exists? @revs.manifest_headers_file()
    file_status.should == true 
    
    YAML.load(File.open(@revs.manifest_headers_file())).class.should == Hash
  end
  
  it "should have a list of headers required for registration in the manifest headers file" do
    @revs.get_manifest_section(@revs.manifest_register_section_name()).size.should > 0
    (@revs.get_manifest_section(@revs.manifest_register_section_name()).keys - ["sourceid", "label", "filename"]).should == [] #headers required to register
  end
  
  it "should have a list of headers required for metadata updating in the manifest headers file" do
     @revs.get_manifest_section(@revs.manifest_metadata_section_name()).size.should > 0
     (@revs.get_manifest_section(@revs.manifest_metadata_section_name()).keys - ["marque", "model", "people", "entrant", "photographer", "current_owner", "venue", "track", "event",
            "location", "year", "description", "model_year", "model_year", "group_or_class", "race_data", "metadata_sources",
            "vehicle_markings", "inst_notes", "prod_notes", "has_more_metadata", "hide", "format", "collection_name"]).should == []
  end
  
  it "should return when true when given a clean sheet to check for headers required for registration and metadata updating" do
    clean_sheet = Dir.pwd + "/spec/sample-csv-files/clean-sheet.csv"
    @revs.valid_to_register(clean_sheet).should == true
    @revs.valid_for_metadata(clean_sheet).should == true
  end
  
  it "should return true for registration, but fail for metadata when year is replaced with date" do
     clean_sheet = Dir.pwd + "/spec/sample-csv-files/date-instead-of-year.csv"
     @revs.valid_to_register(clean_sheet).should == true
     @revs.valid_for_metadata(clean_sheet).should == false
  end
  
  it "should return false for registration and metadata when sourceid is not present" do
    clean_sheet = Dir.pwd + "/spec/sample-csv-files/no-sourceid.csv"
    @revs.valid_to_register(clean_sheet).should == false
    @revs.valid_for_metadata(clean_sheet).should == false
  end

end
