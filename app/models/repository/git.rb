#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Repository::Git < Repository::Abstract

  class << self
    
    def truncate_revision(revision)
      super.first(7)
    end

    def enabled?
      SCM_GIT_ENABLED
    end
    
  end

  def latest_revision
    repo.commits.first.id
  end
  memoize :latest_revision

  def unified_diff(path, revision_a, revision_b)
    return '' unless active?

    text = repo.git.native('diff', {}, revision_a, revision_b, '--', [path])
    return '' if text.empty? || text =~ /^Binary files /

    "#--- #{revision_a}\n#+++ #{revision_b}\n#{text}"
  rescue Grit::Git::CommandFailed
    ''
  end

  # Returns the revision history for a path starting with a given revision
  def history(path, revision = nil, limit = 100)
    return [] unless active? 

    #might be slow
    repo.log(revision || latest_revision, path).first(limit).map {|commit| commit.id }
  end

  def sync_changesets
    return unless active?
    
    last_changeset = changesets.find :first, :select => 'revision', :order => 'created_at DESC'
    
    revisions = if last_changeset
      repo.commits_between("#{last_changeset.revision}","HEAD")
    else
      repo.commits('HEAD',false)
    end
    
    synchronize!(revisions.map { |item| item.id })
  end

  def repo
    Grit::Repo::new(path)
  end
  memoize :repo

  protected

    def new_changeset(revision)
      commit = repo.commit(revision)

      options = { :max_count => 1,
                  :find_copies_harder => true,
                  :pretty => "raw" }
      output = repo.git.native(:show,options,[revision])
      if output =~ /diff --git a/
        output = output.sub(/.+?(diff --git a)/m, '\1')
      else
        output = ''
      end
      diffs = Grit::Diff.list_from_string(repo,output)

      node_data = { :added => [], :copied => [], :updated => [], :deleted => [], :moved => [] }

      diffs.each do |diff|
        if diff.new_file
          node_data[:added] << diff.a_path
        elsif diff.deleted_file
          node_data[:deleted] << diff.a_path
        elsif diff.renamed_file && diff.similarity_index == 100
          node_data[:copied] << [diff.b_path, diff.a_path, commit.parents[0].id]
        elsif diff.renamed_file
          node_data[:moved] << [diff.b_path, diff.a_path, commit.parents[0].id]
        else # modified
          node_data[:updated] << diff.a_path
        end
      end

      changeset = changesets.build :revision => revision.to_s, 
        :author => commit.committer.name, 
        :log => commit.message.squish,
        :created_at => commit.date
      [changeset, node_data]
    end

end
