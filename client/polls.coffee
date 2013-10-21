Template.polls.events(
  'submit #newPollForm' : (event, template) ->
    input = event.target.elements[0]
    name = input.value
    console.log "New Poll with name: #{name}"
    Polls.insert({name: name, create_date: new Date(), create_user: Meteor.userId(), votes: []})
    input.value=""
    return false
)

Template.onepoll.hasVoted = () ->
  poll = Polls.findOne(Session.get("poll_id"))
  revote = Session.get("revote")
  return true if hasVoted(poll) and not revote

hasVoted = (poll) ->
   _.contains(_.pluck(poll.votes, "user_id"), Meteor.userId())

Template.vote.getOrderedItems = () ->
  votes = findUsersVote this, Meteor.userId()
  if votes
    votes.votes.concat _.difference(this.items, votes.votes)
  else
    this.items

findUsersVote = (poll, user_id) ->
  _.find(poll.votes, (vote) ->
    return vote.user_id is user_id
  )

Template.vote.events(
  'submit #newItemForm' : (event, template) ->
    pollId = $("#poll-id").val()
    name =  $("#item-name").val()
    Polls.update(pollId, $addToSet: items: name)
    $("#item-name").val("")
    return false
  'click #submit-vote' : (event, template) ->
    sortedIDs = $(".sortable").sortable( "toArray" )
    pollId = $(event.target).data("poll-id")
    poll = Polls.findOne(pollId)
    if hasVoted(poll)
      Polls.update( pollId, { $pull: { "votes" : { user_id: Meteor.userId() } } } )
    
    data =
      user_id: Meteor.userId()
      votes: sortedIDs
      date: new Date()
    Polls.update(pollId, $addToSet: votes: data)
    Session.set("revote", null)
)
        
Template.vote.rendered = () ->
  $( ".sortable" ).sortable()
  $( ".sortable" ).disableSelection()

Template.results.events(
  'click #revote' : (event, template) ->
    pollId = Session.get("poll_id")
    Session.set("revote", true)
)

Template.results.newItems = () ->
  votes = findUsersVote this, Meteor.userId()
  this.items.length > votes.votes.length

Template.results.sortedResults = () ->
  poll = Polls.findOne(Session.get("poll_id"))
  result = []
  for item in poll.items
    obj = {name: item, points: pointsFor(poll, item)}
    result.push obj
  _.sortBy(result, (obj) ->
    return obj.points * -1
  )

pointsFor = (poll, item) ->
  points = 0
  total = poll.items.length
  for vote in poll.votes
    location = _.indexOf(vote.votes, item)
    if location>=0
      points = points + (total - location)
    else
      points = 0
  points
