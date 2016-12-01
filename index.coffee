GitIssueView = require './GitIssueView'
request = require 'request'

request = request.defaults
  headers:
    'User-Agent': 'ubergeekzone/bitbucket-issues'

GH_REGEX = /^(https:\/\/|git@)bitbucket\.org(\/|:)([-\w]+)\/([-\w]+)(\.git)?$/

issuesUrl = (info) ->
  "https://api.bitbucket.org/2.0/repositories/#{info.user}/#{info.repo}/issues"

getOriginURL = -> atom.project.getRepositories()[0]?.getOriginURL() or null

isBitBucketRepo = ->
  u = getOriginURL()
  return false unless u
  m = u.match GH_REGEX
  if m
    {
      user: m[3]
      repo: m[4]
    }
  else
    false

fetchIssues = (callback) ->
  request issuesUrl(isBitBucketRepo()), (err, resp, body) ->
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
  configDefaults:
    username: ''
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
          issues: issues
