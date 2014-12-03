module Crystal
  class GitHubDependency < Dependency
    def initialize(repo, name)
      unless repo =~ /(.*)\/(.*)/
        raise ProjectError.new("Invalid GitHub repository definition: #{repo}")
      end

      @author = $1
      @repository = $2
      @target_dir = ".deps/#{@author}-#{@repository}"

      super(name || @repository)
    end

    def install
      unless Dir.exists?(@target_dir)
        `git clone https://github.com/#{@author}/#{@repository}.git #{@target_dir}`
      end
      `ln -sf ../#{@target_dir}/src libs/#{name}`

      if @locked_version
        if current_version != @locked_version
          `git -C #{@target_dir} checkout -q #{@locked_version}`
        end
      else
        @locked_version = current_version
      end
    end

    def current_version
      `git -C #{@target_dir} rev-parse HEAD`.chomp
    end
  end
end