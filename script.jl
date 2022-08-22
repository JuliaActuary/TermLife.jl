using LifeContingencies
using MortalityTables
using OffsetArrays: Origin, no_offset_view
using Yields
import LifeContingencies: V, ä     # pull the shortform notation into scope
import MortalityTables: MortalityTable

# make a matrix
select_ultimates = map(MortalityTables.table, 3299:3308)
selects = map(select_ultimate -> select_ultimate.select, select_ultimates)
ultimates = map(select_ultimate -> select_ultimate.ultimate, select_ultimates)
ultimates = reduce(hcat, ultimates)
println(size(ultimates)) # (103, 10)
selects = reduce(hcat, selects)
println(size(selects)) # (10, ), but we want (10, 78, 25)

# Select vectors are of different lengths. Not able to concat within select.
size(selects[1][18]) # (103, )
size(selects[1][19]) # (102, )

# I guess I would have to truncate each one to size 25?
# I think I am going about this the wrong way.

