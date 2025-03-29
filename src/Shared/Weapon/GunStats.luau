local module = {}

local gunstats = {}
gunstats.EquipTime = 0.36 -- how long does it take to draw the gun
gunstats.AimTime = 0.16
gunstats.AimWalkSpeedDecreaseFactor = 0.5
gunstats.Burst = math.huge -- math.huge for full auto
gunstats.CooldownBetweenShots = 0.1
gunstats.AnimationIDhold = 913402848
gunstats.WeaponSwayMultiplier = 0.21 -- higher = more sway
gunstats.RecoilCosinePeriod = 8-- 2pi * this number
gunstats.RecoilBase = 1000 -- this^-x
gunstats.RecoilTimeScale = 3
gunstats.RecoilMinScale = 0.1
gunstats.RecoilMaxScale = 0.16
gunstats.MinSpread = math.rad(1)
gunstats.MaxSpread = math.rad(10)
gunstats.Climb = 36 -- climb/this number
gunstats.RecoilDivisor = 3
-- IMPORTANT!!!!!!
-- Should double check the following, I was idiot back then
-- IMPORTANT!!!!!!





gunstats.ReloadTime = 1.5 -- how long does it take to reload the gun
gunstats.SmokeWait = 1 -- how long until smoke
gunstats.Damage = 100
gunstats.FullDamage = 10 -- under this distance, full damage
gunstats.DropOff = 0.1 -- each stud minus damage by 1
gunstats.Brittleness = 10 -- this number times density when bullet in wall
gunstats.BulletDestroy = 600 -- after this distance, deal no damage
gunstats.BulletLength = 45 -- length of the visible bullet
gunstats.CastLength = 1 -- length of each raycast
--gunstats.StepCoolDown = 0.1 -- wait this long before the bullet take the next step
gunstats.Gravity = -1 -- how much the bullet is affected by gravity
gunstats.KnockBack = 1
gunstats.MinRecoil = 0.1
gunstats.SpreadDecay = 1 -- speed to re-aim, affect weapon sway (probably)
gunstats.MaxRecoil = 0.36 -- for each shot
gunstats.Farest = 1 -- fire many shots, recoil add up, we need cap
gunstats.RecoilRecover = 1 -- un-recoil time
gunstats.RecoilDecay = 0.1 -- wait a bit before recoil happen
gunstats.Speed = 0.1 -- wait time before step
gunstats.SlowDown = 1 -- walkspeed slow
gunstats.NumProjectile = 1 -- bigger then 1 = shotgun
gunstats.DisplayName = "Refactored Pistol"
-- each bullet apply its own spread and recoil in numprojectile

gunstats.HowFarSlideMove = 1 -- non optimal stats, will be improved
gunstats.HowLongSlideComeBack = 1
gunstats.magsize =  6
gunstats.MaxReserve = 60
gunstats.Magnification = 1 -- will be in attachments

module["ASR"] = gunstats

-- below is our CHA stats
gunstats = {}
gunstats.EquipTime = 1 -- how long does it take to draw the gun
gunstats.AimTime = 0.3
gunstats.AimWalkSpeedDecreaseFactor = 0.5
gunstats.Burst = 1 -- math.huge for full auto
gunstats.CooldownBetweenShots = 0.5
gunstats.AnimationIDhold = 913402848
gunstats.WeaponSwayMultiplier = 0.36 -- higher = more sway
gunstats.RecoilCosinePeriod = 8-- 2pi * this number
gunstats.RecoilBase = 1000 -- this^-x
gunstats.RecoilTimeScale = 2
gunstats.RecoilMinScale = 0.30
gunstats.RecoilMaxScale = 0.36
gunstats.MinSpread = math.rad(5)
gunstats.MaxSpread = math.rad(10)
gunstats.Climb = 70 -- climb/this number
gunstats.RecoilDivisor = 1.6
-- IMPORTANT!!!!!!
-- Should double check the following, I was idiot back then
-- IMPORTANT!!!!!!





gunstats.ReloadTime = 1.5 -- how long does it take to reload the gun
gunstats.SmokeWait = 1 -- how long until smoke
gunstats.Damage = 100
gunstats.FullDamage = 10 -- under this distance, full damage
gunstats.DropOff = 0.1 -- each stud minus damage by 1
gunstats.Brittleness = 10 -- this number times density when bullet in wall
gunstats.BulletDestroy = 600 -- after this distance, deal no damage
gunstats.BulletLength = 45 -- length of the visible bullet
gunstats.CastLength = 1 -- length of each raycast
--gunstats.StepCoolDown = 0.1 -- wait this long before the bullet take the next step
gunstats.Gravity = -1 -- how much the bullet is affected by gravity
gunstats.KnockBack = 1
gunstats.MinRecoil = 0.1
gunstats.SpreadDecay = 1 -- speed to re-aim, affect weapon sway (probably)
gunstats.MaxRecoil = 0.36 -- for each shot
gunstats.Farest = 1 -- fire many shots, recoil add up, we need cap
gunstats.RecoilRecover = 1 -- un-recoil time
gunstats.RecoilDecay = 0.1 -- wait a bit before recoil happen
gunstats.Speed = 0.1 -- wait time before step
gunstats.SlowDown = 1 -- walkspeed slow
gunstats.NumProjectile = 1 -- bigger then 1 = shotgun
gunstats.DisplayName = "Gun-gun"
-- each bullet apply its own spread and recoil in numprojectile

gunstats.HowFarSlideMove = 1 -- non optimal stats, will be improved
gunstats.HowLongSlideComeBack = 1
gunstats.magsize =  14
gunstats.MaxReserve = 60
gunstats.Magnification = 1 -- will be in attachments

module["m1 garand"] = gunstats

-- below is the AK53 stats
gunstats = {}
gunstats.EquipTime = 0.36 -- how long does it take to draw the gun
gunstats.AimTime = 0.16
gunstats.AimWalkSpeedDecreaseFactor = 0.5
gunstats.Burst = math.huge -- math.huge for full auto
gunstats.CooldownBetweenShots = 0.1
gunstats.AnimationIDhold = 913402848
gunstats.WeaponSwayMultiplier = 0.21 -- higher = more sway
gunstats.RecoilCosinePeriod = 8-- 2pi * this number
gunstats.RecoilBase = 1000 -- this^-x
gunstats.RecoilTimeScale = 3
gunstats.RecoilMinScale = 0.2
gunstats.RecoilMaxScale = 0.26
gunstats.MinSpread = math.rad(2)
gunstats.MaxSpread = math.rad(10)
gunstats.Climb = 70 -- climb/this number
gunstats.RecoilDivisor = 3
-- IMPORTANT!!!!!!
-- Should double check the following, I was idiot back then
-- IMPORTANT!!!!!!





gunstats.ReloadTime = 1.5 -- how long does it take to reload the gun
gunstats.SmokeWait = 1 -- how long until smoke
gunstats.Damage = 100
gunstats.FullDamage = 10 -- under this distance, full damage
gunstats.DropOff = 0.1 -- each stud minus damage by 1
gunstats.Brittleness = 10 -- this number times density when bullet in wall
gunstats.BulletDestroy = 600 -- after this distance, deal no damage
gunstats.BulletLength = 45 -- length of the visible bullet
gunstats.CastLength = 1 -- length of each raycast
--gunstats.StepCoolDown = 0.1 -- wait this long before the bullet take the next step
gunstats.Gravity = -1 -- how much the bullet is affected by gravity
gunstats.KnockBack = 1
gunstats.MinRecoil = 0.1
gunstats.SpreadDecay = 1 -- speed to re-aim, affect weapon sway (probably)
gunstats.MaxRecoil = 0.36 -- for each shot
gunstats.Farest = 1 -- fire many shots, recoil add up, we need cap
gunstats.RecoilRecover = 1 -- un-recoil time
gunstats.RecoilDecay = 0.1 -- wait a bit before recoil happen
gunstats.Speed = 0.1 -- wait time before step
gunstats.SlowDown = 1 -- walkspeed slow
gunstats.NumProjectile = 1 -- bigger then 1 = shotgun
gunstats.DisplayName = "AK"
-- each bullet apply its own spread and recoil in numprojectile

gunstats.HowFarSlideMove = 1 -- non optimal stats, will be improved
gunstats.HowLongSlideComeBack = 1
gunstats.magsize =  6
gunstats.MaxReserve = 60
gunstats.Magnification = 1 -- will be in attachments

module["AK53"] = gunstats

return module
