class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :tweet

  # after_create_commit {broadcast_replace_later_to "notification_bell",
  #                                                 target:"#{current_user.id}_notification_bell_icon",
  #                                                 partial:"shared/bellnotification",
  #                                                 locals: {current_user: current_user}
  # }
end
