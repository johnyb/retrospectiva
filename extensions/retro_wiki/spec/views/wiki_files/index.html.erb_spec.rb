#require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "spec_helper"

describe "/wiki_files/index.html.erb" do
  fixtures :projects
  
  before(:each) do
    @project = mock_model(Project, :wiki_title => 'Test')
    Project.stub!(:current).and_return(@project)
    file = mock_model(WikiFile, :wiki_title => 'Test', :file_name => 'test.png',
                     :content_type => 'image/png', :size => 12348)
    file.stub!(:readable?).and_return(true)
    file.stub!(:format?).and_return(false)
    assigns[:files] = [file].paginate :page => 1

    template.stub!(:permitted?).and_return(false)
    template.stub!(:permitted?).with(:wiki_files, :delete).and_return(true)
  end
  
  def do_render
    render "wiki_files/index.html.erb"
  end
    
  it "should render without errors" do
    do_render
  end

  it "should render one file" do
    do_render
    response.should have_tag('tbody#groups') do
      with_tag('tr')
    end
  end
  
  it "should show a delete button for authorized users" do
    do_render
    response.should have_tag('a', _("Delete"))
  end

  it "should not show a delete button for unauthorized users" do
    template.stub!(:permitted?).with(:wiki_files, :delete).and_return(false)
    do_render
    response.should_not have_tag('a', _("Delete"))
  end

end

