@Polls = new Meteor.Collection("polls")
Meteor.publish('polls', () -> 
  Polls.find()
)

Meteor.publish("userData", () ->
  Meteor.users.find({_id: this.userId}, {fields: {'services.google.email':1}})
)

Meteor.publish('allUserData', () ->
  Meteor.users.find({}, {fields:{'profile':1, 'services.google.email':1}})
)

###
Security
###
Polls.allow(
  insert: (user_id, poll) ->
    return true
  update: (user_id, poll, fieldnames, modifier) ->
    return true
  remove: (user_id, poll) ->
    return poll.user_id == user_id
)
