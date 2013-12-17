$(document).ready (function(){
    if (typeof msp != 'undefined')
    {
        msp.outline = {};

        msp.outline.COLLAPSE = "msp-collapse";
        msp.outline.EXPAND = "msp-expand";
        msp.outline.EXPAND_OR_COLLAPSE = new RegExp(msp.outline.COLLAPSE + "|" +  msp.outline.EXPAND, "ig");

        msp.outline.getTaskId = function(tr) {
            return parseInt(tr.getAttribute("task-id"));
        }
        msp.outline.getNextTaskId = function(tr) {
            return parseInt(tr.getAttribute("next-task-id"));
        }
        msp.outline.getTaskLevel = function(tr) {
            return parseInt(tr.getAttribute("level"));
        }

        msp.outline.getTaskStateCell = function(tr) {
            var cell = tr.cells.item(1);
            return cell;
        }

        msp.outline.getTaskState = function(taskStateCell) {
            var className = taskStateCell.className;
            if (className.indexOf(msp.outline.COLLAPSE)!=-1) {
                className = msp.outline.COLLAPSE;
            } else 
            if (className.indexOf(msp.outline.EXPAND)!=-1){
                className = msp.outline.EXPAND;
            } 
            return className;
        }

        msp.outline.setTaskState = function (tr, state) {
            var cell = msp.outline.getTaskStateCell(tr);
            var className = cell.className;
            className = className.replace(msp.outline.EXPAND_OR_COLLAPSE, state);
            cell.className = className;

            var display;
            switch (state) {
                case msp.outline.COLLAPSE:
                    display = "";
                    break;
                case msp.outline.EXPAND:
                    display = "none";
                    break;
                default:
                    return;
            }
            var level = msp.outline.getTaskLevel(tr);
            var taskId = msp.outline.getTaskId(tr);
            var nextTaskId = msp.outline.getNextTaskId(tr);
            var lastRowIndex, tmpLevel;
            var i=tr.rowIndex + 1;
            var rows = tr.parentNode.parentNode.rows;
            if (isNaN(nextTaskId)){
                lastRowIndex = rows.length;
            } else {
                lastRowIndex = i + (nextTaskId - taskId) - 1;
            }
            for (; i<lastRowIndex; i++) {
        //debugger;    
                tr = rows.item(i);
                if (msp.outline.getTaskLevel(tr) <= level) {
                    break;
                }
                tr.style.display = display;
                cell = msp.outline.getTaskStateCell(tr);
                state = msp.outline.getTaskState(cell)

                if (state == msp.outline.EXPAND) {
                    nextTaskId = msp.outline.getNextTaskId(tr);
                    tmpLevel = msp.outline.getTaskLevel(tr);
                    if (isNaN(nextTaskId)){
                        while (++i < lastRowIndex) {
                            tr = rows.item(i);
                            if (msp.outline.getTaskLevel(tr) <  tmpLevel){
                                break;
                            }
                        };
                        i--;
                    } else {
                        taskId = msp.outline.getTaskId(tr);
                        i += (nextTaskId - taskId) -1;
                        continue;
                    }
                }

            }
        }

        msp.outline.toggleTaskState = function (tr) {
            var cell = msp.outline.getTaskStateCell(tr);
            var taskState = msp.outline.getTaskState(cell);
            switch (taskState) {
                case msp.outline.COLLAPSE:
                    taskState = msp.outline.EXPAND;
                    break;
                case msp.outline.EXPAND:
                    taskState = msp.outline.COLLAPSE;
                    break;
                default:
                    return;
            }
            msp.outline.setTaskState(tr, taskState);
        }
    }
});
