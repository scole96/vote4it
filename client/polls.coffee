Template.polls.events(
  'submit #newPollForm' : (event, template) ->
    input = event.target.elements[0]
    name = input.value
    id = Polls.insert({name: name, create_date: new Date(), create_user: Meteor.userId(), votes: {}})
    input.value=""
    Router.go("/poll/#{id}")
    return false
)

Template.onepoll.hasVoted = () ->
  poll = Polls.findOne(Session.get("poll_id"))
  poll.votes[Meteor.userId()] and not Session.get("revote")

Template.vote.getOrderedItems = () ->
  vote = this.votes[Meteor.userId()]
  if vote
    vote.votes.concat _.difference(this.items, vote.votes)
  else
    this.items

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
    if poll.votes[Meteor.userId()]
      Polls.update( pollId, $unset: "votes" : Meteor.userId()  )

    data = 
      votes: sortedIDs
      date: new Date()    
    setModifier = { $set: {} };
    setModifier.$set['votes.' + Meteor.userId()] = data

    Polls.update(pollId, setModifier)
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
  vote = this.votes[Meteor.userId()]
  if vote
    this.items.length > vote.votes.length

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
  for vote in _.values poll.votes
    location = _.indexOf(vote.votes, item)
    if location>=0
      points = points + (total - location)
    else
      points = 0
  points
