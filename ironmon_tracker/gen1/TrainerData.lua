-- Trainer metadata from the GBA tracker is intentionally not initialized for
-- RBY. Native trainer-table parsing is added separately and live battle data
-- remains authoritative in the meantime.
Gen1TrainerData = {}

function Gen1TrainerData.initialize()
	TrainerData.Trainers = {}
	TrainerData.OrderedIds = {}
	TrainerData.GymTMs = {}
	TrainerData.CommonTrainers = {}
	TrainerData.FinalTrainer = {}
	for key in pairs(TrainerData.IsRand or {}) do TrainerData.IsRand[key] = false end
end

TrainerData.initialize = Gen1TrainerData.initialize

return Gen1TrainerData
