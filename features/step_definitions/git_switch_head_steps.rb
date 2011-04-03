Given /^a git repository "([^"]*)"$/ do |name|
  r = Repository::Git.new
  r.path = "tmp/#{name}"
  @repo = r.repo '/'
end

When /^I list the heads$/ do
  @heads = @repo.heads
end

Then /^the list of heads should contain (\d+) entries$/ do |count|
  @heads.size.should contain(count)
end

When /^the current head is "([^"]*)"$/ do |head|
  @current_head = @repo.get_head(head)
end

When /^I switch to "([^"]*)"$/ do |head|
  @current_head = @repo.get_head(head)
end

Then /^"([^"]*)" contains the entries$/ do |path, table|
  # table is a Cucumber::Ast::Table
  contents = (@repo.tree(@current_head.name) / path).contents.map do |item|
    [item.class.to_s.split('::').last, item.name]
  end
  table.diff!(contents)
end

