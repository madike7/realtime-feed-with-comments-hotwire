Rails::Html::WhiteListSanitizer.allowed_tags << 'video'
Rails::Html::WhiteListSanitizer.allowed_tags << 'audio'
Rails::Html::WhiteListSanitizer.allowed_tags << 'source'
Rails::Html::WhiteListSanitizer.allowed_attributes << 'controls'
Rails::Html::WhiteListSanitizer.allowed_attributes << 'style'
Rails::Html::WhiteListSanitizer.allowed_attributes << 'poster'
