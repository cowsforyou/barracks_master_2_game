//-- Adding Abilities

1) Create the ability itself.
1.1) E.g. the ability name can be "fire".
1.2) All abilities must be created in the npc_abilities_custom.txt file.

2) Creating a standalone file (optional).
2.1) You can create a standalone file for easy reference, but this file does nothing on it's own. 
2.2) The file must be referenced in the npc_abilities_custom.txt file.
2.3) To reference the file, type in the code #base followed by the file location.
2.4) E.g. #base "fire.txt"
2.5) In the standalone file you will also need to add your code within the brackets "DOTAAbilities"{ }.
2.6) You can now make changes solely in the standalone file.

3) Attach the ability to a unit.
3.1) All units should be listed in npc_units_custom.txt.
3.2) You may also create standalone files for units by following the instructions listed in step 2.
3.3) Each unit has a list of abilities that can be specified to them. ("Ability1", "Ability2", etc)
3.4) Type in the name of the ability you created earlier into the unit abilities.
3.5) E.g. "Ability1" "fire".

You are done! If you want to make your ability researchable then continue on.

4) Create an ability that sets the research parameters.
4.1) The new ability should have a research_ prefix to your original ability name.
4.2) E.g. "research_fire"
4.3) This new ability with the research parameters should be added into the npc_abilities_custom.txt file.

5) Create a disabled version of your ability.
5.1) This will be the placeholder before the ability becomes active/researched.
5.2) This can be done with creating a new ability and adding a _disabled suffix to your ability name.
5.3) E.g. "fire_disabled"
5.4) This new ability should also be added into npc_abilities_custom.txt.

6) Attach the ability to a unit.
6.1) The research ability and the actual ability can be in different places.
6.2) For simplicity in these instructions, we will assume it is on the same unit.
6.3) E.g. "Ability1" "fire" "Ability2" "fire_disabled" "Ability3" "research_fire"

7) Add research instructions to the tech tree.
7.1) Add this line in: "fire" {"research" "1" "research_fire" "1"}

8) Add a way to cancel the research
8.1) Create a new cancel item with the item_ prefix to your research ability.
8.2) This should be added into npc_items_custom.txt.
8.3) E.g. "item_research_fire".

You are done adding an ability that can be researched/upgraded!