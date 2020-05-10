//-- Adding Abilities

1) Create the ability itself.
1.1) E.g. the ability name can be "fire".
1.2) All abilities must be created in the npc_abilities_custom.txt file.
1.3) You can create a standalone file for easy reference, but this file does nothing on it's own. The code must be copied into the npc_abilities_custom file to work.

2) Attach the ability to a unit.
2.1) All units should be listed in npc_units_custom.txt. 
2.2) Each unit has a list of abilities that can be specified to them. ("Ability1", "Ability2", etc)
2.3) Type in the name of the ability you created earlier into the unit abilities.
2.4) E.g. "Ability1" "fire"

You are done! If you want to make your ability researchable then continue on.

3) Create an ability that sets the research parameters.
3.1) The new ability should have a research_ prefix to your original ability name.
3.2) E.g. "research_fire"
3.3) This new ability with the research parameters should be added into the npc_abilities_custom.txt file.

4) Create a disabled version of your ability.
4.1) This will be the placeholder before the ability becomes active/researched.
4.2) This can be done with creating a new ability and adding a _disabled suffix to your ability name.
4.3) E.g. "fire_disabled"
4.4) This new ability should also be added into npc_abilities_custom.txt.

5) Attach the ability to a unit.
5.1) The research ability and the actual ability can be in different places.
5.2) For simplicity in these instructions, we will assume it is on the same unit.
5.3) E.g. "Ability1" "fire" "Ability2" "fire_disabled" "Ability3" "research_fire"

6) Add research instructions to the tech tree.
6.1) Add this line in: "fire" {"research" "1" "research_fire" "1"}

7) Add a way to cancel the research
7.1) Create a new cancel item with the item_ prefix to your research ability.
7.2) This should be added into npc_items_custom.txt.
7.3) E.g. "item_research_fire".

You are done adding an ability that can be researched/upgraded!