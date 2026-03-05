.class Lr/n$a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lr/j;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lr/n;->a(Lr/o;Lr/i;Ljava/lang/Runnable;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic a:Lr/i;

.field final synthetic b:Lr/o;


# direct methods
.method constructor <init>(Lr/o;Lr/i;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p1, p0, Lr/n$a;->b:Lr/o;

    iput-object p2, p0, Lr/n$a;->a:Lr/i;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public a()I
    .locals 1

    iget-object v0, p0, Lr/n$a;->a:Lr/i;

    iget v0, v0, Lr/i;->c:I

    return v0
.end method

.method public b()Z
    .locals 1

    iget-object v0, p0, Lr/n$a;->a:Lr/i;

    invoke-virtual {v0}, Lr/i;->F()Z

    move-result v0

    return v0
.end method
