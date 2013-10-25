
# Define Minimongo collections to match server/publish.js.
@Polls = new Meteor.Collection("polls")

Meteor.autosubscribe( () ->
  Meteor.subscribe("allUserData");
)
##### Tracking selected list in URL #####
Router.configure
  layout: "layout"
  notFoundTemplate: "notFound"
  loadingTemplate: "loading"


Router.map ->
  @route "poll", path: "/poll/:poll_id", controller: "PollController"
  @route "polls", path: "/", controller: "PollsController"

class @PollsController extends RouteController 
  template: 'polls'
  
  waitOn: ->
    Meteor.subscribe("polls")
  
  data: -> 
    console.log "in polls data"
    return Polls.find()

class @PollController extends RouteController 
  template: 'onepoll'
  
  waitOn: ->
    Meteor.subscribe("polls")
  
  data: -> 
    console.log "in poll data with pollId: #{@params.poll_id}"
    return Polls.findOne(@params.poll_id)
