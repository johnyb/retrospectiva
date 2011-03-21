#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Repository::Git::Node < Repository::Abstract::Node
 
  def initialize(repos, path, selected_rev = nil, skip_check = false, blob_info = nil)
    super(repos, sanitize_path(path), selected_rev || repos.latest_revision)
    @blob_info = blob_info
    raise_invalid_node_error! unless skip_check || exists?
  end

  def revision
    revision_for_path(path)
  end
  memoize :revision

  def author
    commit.author.name
  end

  def date
    commit.date
  end
  
  def log
    commit.message
  end

  def dir?
    node[:contents].class.to_s == 'Grit::Tree'
  end

  def sub_nodes
    return [] unless dir?

    node[:contents].contents.map do |content|
      blob = content.class.to_s == 'Grit::Blob' ? to_hash(content) : nil
      self.class.new(repos, File.join(node[:path],content.name), selected_revision, true, blob)
    end.compact.sort_by {|n| [n.content_code, n.name.downcase] }
  end
  memoize :sub_nodes

  def content
    @content = true
    dir? ? nil : blob.data
  end

  def mime_type
    dir? ? nil : guess_mime_type
  end

  def size
    dir? ? 0 : node[:contents].size
  end

  def sub_node_count
    dir? ? node[:contents].contents.size : 0
  end

  # Returns true if the selected node revision mathces the latest repository revision
  def latest_revision?
    selected_revision == 'HEAD' || selected_revision == repos.latest_revision
  end

  protected

    def exists?
      ['blob', 'tree'].include?(node[:type]) and revision.present?
    end
    
    def commit
      @commit ||= repos.repo.commit(revision)
    end

    def blob
      @blob ||= dir? ? nil : repos.repo.blob(node[:sha])
    end
    
    def node
      if @blob_info
        @blob_info
      elsif repos.repo.commit(selected_revision)
        tree = repos.repo.commit(selected_revision).tree
        tree = tree / path unless root?
        to_hash(tree)
      else
        {}
      end
    end
    memoize :node
        
    def sanitize_path(value)
      value.split('/').reject(&:blank?).join('/')
    end
    
    def sanitize_tree(tree)
      tree.select do |hash| 
        hash.is_a?(Hash) and hash[:path].starts_with?(path) and ['blob', 'tree'].include?(hash[:type])
      end
    end
    
    def root?
      path.blank?    
    end
  
  private

    def revision_for_path(path)
      repos.repo.git.rev_list({},[selected_revision,'--',path]).split("\n").first
    end

    def to_hash(obj)
      case obj.class.to_s
      when 'Grit::Tree'
        { :sha => revision, :path => path, :type => 'tree', :contents => obj }
      when 'Grit::Blob'
        { :sha => revision, :path => path, :type => 'blob', :contents => obj }
      else
        {}
      end
    end

    def guess_mime_type
      guesses = MIME::Types.type_for(name) rescue []
      guesses.any? ? guesses.first : MIME::Types['application/octet-stream'].first
    end

end  
