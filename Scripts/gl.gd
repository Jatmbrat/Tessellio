extends Node

const ROTS := [
	0, TileSetAtlasSource.TRANSFORM_FLIP_H, TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H
	, TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_FLIP_H
	, TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_FLIP_H, TileSetAtlasSource.TRANSFORM_FLIP_V
	, TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V, TileSetAtlasSource.TRANSFORM_TRANSPOSE
]

enum Modes {INITIAL, TARGET, CURRENT, HISTORY}

const QUEUE_SIZE := 100
