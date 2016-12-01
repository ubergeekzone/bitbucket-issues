GitIssueView = require './GitIssueView'
request = require 'request'

request = request.defaults
  headers:
    'User-Agent': 'ubergeekzone/bitbucket-issues'

GH_REGEX =
  /(ssh:\/\/git@bitbucket.org)\/(\w+)\/(\w+).git/

issuesUrl = (info) ->
  "https://api.bitbucket.org/2.0/repositories/#{info.user}/#{info.repo}/issues?q=%28state+%3D+%22new%22+OR+state+%3D+%22open%22%29"

getOriginURL = -> atom.project.getRepositories()[0]?.getOriginURL() or null

isBitBucketRepo = ->
  u = getOriginURL()
  return false unless u
  bitbucketURI = u.split("/");
  m = u.match GH_REGEX
  if m
    {
      user: m[2]
      repo: m[3]
    }
  else
    false
fetchIssues = (callback) ->
  request {"url": issuesUrl(isBitBucketRepo()), "auth": { "user": atom.config.get('bitbucket-issues.username'), "pass": atom.config.get('bitbucket-issues.password'), "sendImmediately": true }}, (err, resp, body) ->
    if err
      callback err
    else
      try
        issues = JSON.parse body
        callback null, issues
      catch err
        console.log 'ERR', body
        callback err

module.exports =
  config:
    username: {
        type: 'string',
        default: 'Please enter your bitbucket email address'
      },
    password: {
        type: 'string',
        default: 'Please enter your bitbucket password'
      }
  activate: ->
    atom.commands.add 'atom-workspace', 'bitbucket-issues:list', ->
      if isBitBucketRepo()
        atom.workspace.open 'bitbucket-issues://list'
      else
        alert 'The current project does not appear to be a BitBucket repo.'
    fetchIssues (err, issues) ->
      if err
        console.error err
        alert 'Error opening issues. Is this a public BitBucket project?'
      atom.workspace.addOpener (uri) ->
        return unless uri.match /^bitbucket-issues:/
        new GitIssueView
          issues: issues.values
