{View} = require 'atom-space-pen-views'
marked = require 'marked'
_ = require 'lodash'

statusToInt = (issue) ->
  switch issue.state
    when 'new' then 0
    when 'open' then 1
  2

module.exports =

class GitIssueView extends View
  @content: ->
    @section 'class':'padded pane-item bitbucket-issues', =>
      @h1 'class':'section-heading', 'BitBucket Issues'
      @div 'data-element':'issue-list'
  constructor: (opt={}) ->
    super
    console.log opt
    {@issues} = opt
    unless @issues.sort? and @issues.map?
      @issues = []
    issueList = @issues
      .sort (a,b) ->
        return statusToInt(a) - statusToInt(b) if a.state isnt b.state
        +a.id - +b.id
      .map (issue) ->
        """
        <h2 class="section-heading issue-#{issue.state}">
          <a href="#{issue.links.html.href}">##{issue.id}: #{issue.title}</a>
        </h2>
        <div>
          #{(marked(issue.content.raw || '')) or ''}
        </div>
        """
    if issueList.length
      issueList.forEach (issue) =>
        @find('[data-element="issue-list"]').append("<div class=block>#{issue}</div>")
    else
      @find('[data-element="issue-list"]').append "<h2 class=section-heading>No issues found</h2><h4>Please note that <tt>bitbucket-issues</tt> doesn't list issues for private repos."

  getTitle: -> 'BitBucket Issues'
  getUri: -> 'bitbucket-issues://list'
