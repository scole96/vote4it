Template.polls.events(
  'submit #newPollForm' : (event, template) ->
    input = event.target.elements[0]
    name = input.value
    console.log "New Poll with name: #{name}"
    Polls.insert({name: name, create_date: new Date(), create_user: Meteor.userId(), votes: []})
    input.value=""
    return false
)

Template.onepoll.events(
  'submit #newItemForm' : (event, template) ->
    pollId = $("#poll-id").val()
    name =  $("#item-name").val()
    result = Meteor.call "addItem", pollId, name
    $("#item-name").val("")
    return false
  'click #submit-vote' : (event, template) ->
    sortedIDs = $(".sortable").sortable( "toArray" )
    pollId = $(event.target).data("poll-id")
    poll = Polls.findOne(pollId)

    Polls.update( pollId, { $pull: { "votes" : { user_id: Meteor.userId() } } }, false, true )

    data =
      user_id: Meteor.userId()
      votes: sortedIDs
      date: new Date()
    Polls.update(pollId, $addToSet: votes: data)
)
        
Template.onepoll.rendered = () ->
  $( ".sortable" ).sortable()
  $( ".sortable" ).disableSelection()

Template.onepoll.points = (item_id) ->
  poll_id = Session.get("poll_id")
  poll = Polls.findOne(poll_id)
  points = 0
  total = poll.items.length
  for vote in poll.votes
    location = _.indexOf(vote.votes, item_id+"")
    points = points + (total - location)
  points
