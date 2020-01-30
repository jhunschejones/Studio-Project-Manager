include Rails.application.routes.url_helpers

module ProjectsHelper
  def self.breadcrumbs_for(opts={})
    breadcrumbs = [{text: "Projects", path: projects_path}]

    project = opts[:project]
    event = opts[:event]
    track = opts[:track]
    track_version = opts[:track_version]
    page_title = opts[:page_title]

    breadcrumbs.push({text: project.title, path: project_path(project)}) if project
    breadcrumbs.push({text: event.title, path: project_event_path(project, event)}) if project && event
    breadcrumbs.push({text: track.title, path: project_track_path(project, track)}) if project && track
    breadcrumbs.push({text: track_version.title, path: project_track_track_version_path(project, track, track_version)}) if project && track && track_version

    breadcrumbs.push({text: page_title[:text], path: ""}) if project && page_title

    breadcrumbs
  end
end
