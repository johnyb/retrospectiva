require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/projects/edit.html.erb" do
  
  before(:each) do
    stub_current_user! :admin? => true
    assigns[:project] = @project = stub_model(Project, :short_name_was => 'any', :short_name => 'any').as_new_record
    assigns[:repositories] = [stub_model(Repository::Git, :name => 'R1')]
  end

  def do_render
    render "/admin/projects/edit.html.erb", :helper => 'admin_area'
  end
    
  it "should render the form" do
    do_render
    response.should have_tag('form[action=?]', admin_project_path(@project)) do
      with_tag 'input', :type => :submit
      with_tag 'a', :href => admin_projects_path
    end
  end
  
  it "should render the page header" do
    template.should_receive(:render).with(:partial => 'header')
    do_render
  end

end

