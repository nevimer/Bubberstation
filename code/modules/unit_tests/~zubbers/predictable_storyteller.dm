/datum/unit_test/predictable_storyteller
	var/expected_result = 0

/datum/unit_test/predictable_storyteller/Run()

	var/list/testing_minds = list()
	for(var/i=1,i<=20,i++)

		var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
		dummy.mind_initialize()
		dummy.mock_client = new()

		if(i<=2)
			dummy.apply_prefs_job(dummy.mock_client, SSjob.GetJobType(/datum/job/head_of_security))
			dummy.mind.add_antag_datum(/datum/antagonist/traitor)
		else
			dummy.apply_prefs_job(dummy.mock_client, SSjob.GetJobType(/datum/job/assistant))

		testing_minds += dummy.mind

	var/returning_ratio = storyteller_get_antag_to_crew_ratio(do_debug=TRUE,minds_to_use_override=testing_minds)

	TEST_ASSERT_EQUAL(returning_ratio, expected_result, "Predictable storyteller did not have the correct antag ratio! Expected result: [expected_result], actual: [returning_ratio].")
