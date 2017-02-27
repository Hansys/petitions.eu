# Periodic tasks
################################################
#
# http://handboek.petities.nl/wiki/Periodic_tasks

#  orphan task
# 82 office response about answer for petition.
# 81 publish answer.
# 80 get answer task
# 79 petition get official reference number
# 78 petition to process task

# Signature maintenance

every :day, at: '1am' do
  # remove unconfirmed signatures
  rake 'signature:delete_old_signatures'
end

every 10.minutes do
  # send a reminder to confirm petition
  rake 'signature:send_reminder'
end


#every 30.minutes do
#  # send a reminder to confirm petition
#  rake 'petition:publish_news_to_subscribers'
#end

#every :day, at: '1am' do
#  # send a reminder to confirm petition
#  rake 'petition:publish_answer_to_subscribers'
#end

# Petition maintenance

#every 8.hours do
#  rake 'petition:handle_overdue_petitions'
#end

every :day, at: '4am' do
  rake 'petition:fix_signature_counts'
end

#every :day, at:  '3am' do
#  rake 'petition:get_reference'
#end

#every :day, at: '2am' do
#  # rake petition:send_answers
#  rake 'petition:get_reference'
#end

#every 12.hours do
#  rake 'petition:get_answer_from_office'
#end

# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
