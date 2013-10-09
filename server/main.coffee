Accounts.onCreateUser((options, user) ->
  console.log "on create user"
  email = getEmail(user)

  #We still want the default hook's 'profile' behavior.
  if options.profile
    user.profile = options.profile

  console.log "New user:"
  console.log user
  return user
)

Meteor.methods (
  addItem: (pollId, name) ->
    poll = Polls.findOne(pollId)
    if poll.nextId
      id = poll.nextId
    else
      id = 1
    nextId = id + 1
    item =
      id: id
      name: name
      added_date: new Date()
      added_by: Meteor.userId()
    Polls.update({_id: pollId, 'items.name': {$ne: item.name}}, {$addToSet: {items: item}, $set: {nextId: nextId}})
)

Accounts.loginServiceConfiguration.remove({
    service: "google"
})

if Meteor.settings.google
  console.log "Configuring google auth based on settings file"
  Accounts.loginServiceConfiguration.insert({
      service: "google",
      clientId: Meteor.settings.google.clientId
      secret: Meteor.settings.google.secret
  })
else
  Accounts.loginServiceConfiguration.insert({
      service: "google",
      clientId: "357514018484-ecc29drjm0vgaebuu4q67grd36il8k3g.apps.googleusercontent.com",
      secret: "n4-T81HiQz_J-bEjHpFEaFlt"
  })
