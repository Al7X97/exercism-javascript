// @ts-check

/**
 * Implement the classes etc. that are needed to solve the
 * exercise in this file. Do not forget to export the entities
 * you defined so they are available for the tests.
 */
export function Size(width=80, height=60) {
    this.width = width;
    this.height = height;
}
    Size.prototype.resize = function(newWidth, newHeight) {
    this.width = newWidth;
    this.height = newHeight;
}

export function Position(x=0, y=0) {
    this.x = x;
    this.y = y;
}
    Position.prototype.move = function(newX, newY) {
    this.x = newX;
    this.y = newY;
}

export class ProgramWindow {
    constructor () {
    this.screenSize = new Size(800, 600)
    this.size = new Size()
    this.position = new Position()
    }
    resize(newSize) {
    const freeWidth = this.screenSize.width - this.position.x
    const safeWidth = Math.max(1, Math.min(newSize['width'], freeWidth))
    const freeHeight = this.screenSize.height - this.position.y
    const safeHeight = Math.max(1, Math.min(newSize['height'], freeHeight))
    this.size.resize(safeWidth, safeHeight);
    }
    move(newPosition) {
    const safeX = 
    (Math.max(newPosition['x'], 0) + this.size.width) > this.screenSize.width ? 
    (this.screenSize.width - this.size.width) : Math.max(newPosition['x'], 0)
   
    const safeY = (Math.max(newPosition['y'], 0) + this.size.height) > this.screenSize.height ? 
    (this.screenSize.height - this.size.height) : Math.max(newPosition['y'], 0)

    this.position.move(safeX, safeY);
    }
    
}
export function changeWindow(newProgramWindow) {
        const newSize = new Size(400, 300)
        const newPostion = new Position(100, 150)
        newProgramWindow.resize(newSize)
        newProgramWindow.move(newPostion)
        return newProgramWindow
   }