{form, select, option, renderable, li, a, br, p, text, h3, h4, b, ul, css, span} = require 'teacup'
sprintf = require('util').format

utils = require './template-utils'

module.exports = renderable ({req, issues, users, allmilestones}) ->
  css 'app'
  h3 ->
    text issues.length + ' issues in API milestones'

  milestones = {}
  nostones = []

# separate by milestone (really, milestone title)

  for i in issues
    if i.milestone?
      milestones[i.milestone.title] ?= []
      milestones[i.milestone.title].push i
    else
      nostones.push i

  accum = {}
  
  for title in Object.keys(milestones).sort utils.datecompare
    h4 'Milestone: ' + title
    ul ->
      for i in milestones[title].sort utils.idcompare # Increasing by id
        utils.issue i, null, null, false
    
  if nostones.length > 0
    h4 'No milestone'
    ul ->
      for i in nostones
        utils.issue i, null, null, false

