{
    :en => {
        :time => {
            :formats => {
                :tiny => lambda { |time,options| "%B, #{time.day.ordinalize}" },
                :medium => lambda { |time,options| "%B, #{time.day.ordinalize} %Y" }
            }
        }
    }
}
