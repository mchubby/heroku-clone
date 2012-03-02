require "fileutils"

module Heroku::Command

  # clone an existing app
  #
  class Clone < Heroku::Command::Base

    # clone [--from APP_NAME1] --to APP_NAME2 [--with-config]
    #
    # clone a Heroku app, along with addons, config, etc.
    #
    # -f, --from APP  # source (existing) App
    # -t, --to APP    # destination (to-be-created) App
    #
    # --with-config   # also copies config keys (use with caution)
    #
    # --from may be omitted if current directory is a Heroku repository
    # You may only clone an app you have access to.
    #
    def index
      from_app = extract_option("--from") || extract_app_in_dir(Dir.pwd)
      to_app   = extract_option("--to")
      extract_option("--with-config", false)

      fail('Missing argument, type "heroku help clone" for help.') if (from_app.nil? || from_app.empty? || to_app.nil? || to_app.empty?)
      fail("This command cannot be performed if Git is not available.") unless has_git?
      begin
        Timeout::timeout(5) do
          loop do
            break if heroku.create_complete?(from_app)
            sleep 1
          end
        end
      rescue Timeout::Error
        fail "App: #{from_app} Status fetch timeout. Please retry later."
      rescue ::RestClient::ResourceNotFound => e
        fail "App: #{from_app} does not exist"
      end
      
      outdirpath = extract_app_in_dir(Dir.pwd).nil? ? ::File.join(Dir.pwd, to_app) : ::File.realdirpath(::File.join('..', to_app));
      if File.exists? outdirpath
        fail "Cannot clone into target directory #{outdirpath}. Please remove the existing file or directory, or chdir into another location and retry"
      end

      display "Cloning #{from_app} to #{to_app}"

      step "creating application #{to_app}"
      to_app = heroku.create(to_app, :stack => heroku.info(from_app)[:stack])
      substep "new app: #{to_app}"

      step "cloning addons"
      clone_addons(from_app, to_app)

      if options[:with_config]
        step "cloning configuration"
        clone_configuration(from_app, to_app)
      end

      step "cloning repository"
      clone_repository(from_app, to_app, outdirpath)

      step "cloning collaborators"
      clone_collaborators(from_app, to_app)

      display "Done."
    end

private ######################################################################

    def step(message, indent=1)
      display "  " * indent + "* " + message
    end


    def substep(message)
      step message, 2
    end


    def clone_addons(from_app, to_app)
      from_addons = heroku.installed_addons(from_app).map { |a| a["name"] }
      to_addons = heroku.installed_addons(to_app).map { |a| a["name"] }
      from_addons.each do |addon|
        if to_addons.select { |a| a == addon }.length > 0
          substep "[SKIP] #{addon} already installed"
        else
          substep "[INST] #{addon}..."
          heroku.install_addon(to_app, addon)
        end
      end
    end


    def clone_configuration(from_app, to_app)
      from_config = heroku.config_vars(from_app).select { |key| not(key =~ /_URI|_URL|_KEY|_SECRET/) }
      heroku.add_config_vars(to_app, from_config)
      from_config.keys.sort.each { |key| substep(key) }
    end


    def clone_repository(from_app, to_app, destdir = '')
      attrs = heroku.info(from_app)
      
      if destdir.empty?
        tempfile = Tempfile.new("heroku-clone")
        checkout_dir = tempfile.path
        tempfile.close!
        tempfile.unlink # may not reference tempfile beyond this point
      else
        checkout_dir = destdir
      end

      substep "[ BY ] #{attrs[:owner]}"
      substep "[FROM] #{attrs[:git_url]}"
      substep "[INTO] #{checkout_dir}"

      FileUtils.mkdir_p(checkout_dir)
      Dir.chdir(checkout_dir) do
        their_stdout_coll = nil
        capture_stderr = [:child, :out]
        
        IO.popen(["git", "clone", "git@#{heroku.host}:#{from_app}.git", "-o", "heroku-clone", checkout_dir, :err=>capture_stderr]) do |their_stdout_coll|
          their_stdout_coll.each {|line| display line}
        end

        IO.popen(["git", "remote", "rm", "heroku-clone", :err=>capture_stderr]) do |their_stdout_coll|
          their_stdout_coll.each {|line| display line}
        end

        IO.popen(["git", "remote", "add", "heroku", "git@#{heroku.host}:#{to_app}.git", :err=>capture_stderr]) do |their_stdout_coll|
          their_stdout_coll.each {|line| display line}
        end

        IO.popen(["git", "push", "heroku", "master", :err=>capture_stderr]) do |their_stdout_coll|
          their_stdout_coll.each {|line| display line}
        end
      end
    end


    def clone_collaborators(from_app, to_app)
      owner_email = heroku.info(from_app)[:owner]
      from_collabs = heroku.list_collaborators(from_app).delete_if { |c| c[:email] == owner_email }.map { |c| c[:email] }
      from_collabs.each do |collab|
        substep "adding #{collab}"
        heroku.add_collaborator(to_app, collab)
      end
    end

  end
end