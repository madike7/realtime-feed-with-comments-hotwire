json.extract! user, :id, :username #kanw extract apo ton user to id kai to username tou
# ta keys pou thelw gia to action text
json.sgid user.attachable_sgid # gia na kserei to action text poio partial na kanei render
json.content render(partial: "users/user_mention", locals: { user: user }, formats: [:html]) # otan kanw edit sti forma, kanw render to idio partial gia na deixnei akrivws to idio 

# an paw sto /mentions.json ston browser vlepw olous tous users pou yparxoun sto database,
# mazi me to sgid tous kai to content tous